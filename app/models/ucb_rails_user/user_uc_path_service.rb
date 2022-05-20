require "faraday"

class UcbRailsUser::UserUcPathService

  class << self

    def create_or_update_user_from_ldap_uid(ldap_uid)
      ucpath_entry = ucpath_client.fetch_employee_data(ldap_uid)
      return nil unless ucpath_entry.present?

      User.find_or_initialize_by(ldap_uid: ldap_uid).tap do |user|
        name_entry = parse_name(ucpath_entry)
        user.first_name = name_entry["givenName"]
        user.last_name = name_entry["familyName"]
        user.employee_id = ucpath_entry["identifiers"]&.detect do |id|
          id["type"] == "hr-employee-id"
        end&.fetch("id")
        user.email = parse_email(ucpath_entry)
        user.inactive_flag = false # any way to pull this from the API?
        user.save!
      end
    end

    def parse_name(entry)
      return nil unless entry.present?
      find_name_by_type(entry["names"], "PRF") ||
        find_name_by_type(entry["names"], "PRI")
    end

    def find_name_by_type(names, type)
      names&.detect do |n|
        n.dig("type", "code") == type
      end
    end

    def parse_email(entry)
      email_entry =
        entry["emails"]&.detect do |email|
          email["primary"] == true
        end
      email_entry ||= entry["emails"]&.first # if there's no primary email, grab whatever we can
      email_entry&.fetch("emailAddress")
    end

    def ucpath_client
      UcPathClient.new
    end

  end

  class UcPathClient
    attr_reader :app_id, :app_key, :endpoint

    def initialize
      credentials =
        Rails.application.credentials.ucpath || Rails.application.credentials.hcm
      @app_id  = credentials&.fetch(:app_id)
      @app_key = credentials&.fetch(:app_key)
      @endpoint = credentials&.fetch(:endpoint)
    end

    def fetch_employee_data(ldap_uid)
      if [app_id, app_key, endpoint].any?(&:blank?)
        Rails.logger.warn missing_api_values_message
        return nil
      end

      response =
        Faraday.get("#{endpoint}/employees/#{ldap_uid}") do |req|
          req.params["id-type"] = "campus-uid"
          req.headers["Accept"] = "application/json"
          req.headers["app_id"] = app_id
          req.headers["app_key"] = app_key
        end
      parse_response(response)&.first
    end

    private

    def parse_response(response)
      return nil if !response.success? || response.body.empty?
      JSON.parse(response.body)&.fetch("response")
    end

    def missing_api_values_message
      <<~END_MSG.strip
        It looks like you're trying to use the preferred user name feature of
        ucb_rails_user, but the host app has not provided all of the expected
        credentials to access the UCPath API.
        To resolve this, add an "hcm" section to the Rails credentials file of
        the host app, and provide values for app_id, app_key, and endpoint.
      END_MSG
    end
  end

end

