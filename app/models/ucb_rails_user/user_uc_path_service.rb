require "faraday"

class UcbRailsUser::UserUcPathService

  class << self

    def create_or_update_user_from_employee_id(employee_id)
      ucpath_entry = ucpath_client.fetch_employee_data_with_employee_id(employee_id)
      return nil unless ucpath_entry.present?
      user = User.find_or_initialize_by(employee_id: employee_id)
      update_user_record_from_ucpath_entry!(user, ucpath_entry)
    end

    def create_or_update_user_from_ldap_uid(ldap_uid)
      ucpath_entry = ucpath_client.fetch_employee_data_with_ldap_uid(ldap_uid)
      return nil unless ucpath_entry.present?
      user = User.find_or_initialize_by(ldap_uid: ldap_uid)
      update_user_record_from_ucpath_entry!(user, ucpath_entry)
    end

    def ucpath_client
      UcPathClient.new
    end

    def update_user_record_from_ucpath_entry!(user, ucpath_entry)
      user.tap do |u|
        name_entry = parse_name(ucpath_entry)
        u.first_name = name_entry["givenName"]
        u.last_name = name_entry["familyName"]
        u.employee_id ||= ucpath_entry["identifiers"]&.detect do |id|
          id["type"] == "hr-employee-id"
        end&.fetch("id")
        u.ldap_uid ||= ucpath_entry["identifiers"]&.detect do |id|
          id["type"] == "campus-uid"
        end&.fetch("id")
        u.email = parse_email(ucpath_entry)
        u.inactive_flag = false # any way to pull this from the API?
        u.save!
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

  end

  class UcPathClient
    attr_reader :app_id, :app_key, :endpoint

    def initialize
      base_credentials =
        Rails.application.credentials.ucpath&.with_indifferent_access ||
        Rails.application.credentials.hcm&.with_indifferent_access ||
        Rails.application.credentials.fetch(:"ucb-hcm", {})&.with_indifferent_access
      env_credentials = base_credentials&.fetch(Rails.env, {})
      @app_id  = env_credentials&.fetch(:app_id, nil) || base_credentials&.fetch(:app_id, nil)
      @app_key = env_credentials&.fetch(:app_key, nil) || base_credentials&.fetch(:app_key, nil)
      @endpoint = env_credentials&.fetch(:endpoint, nil) || base_credentials&.fetch(:endpoint, nil)
    end

    def fetch_employee_data_with_ldap_uid(ldap_uid)
      fetch_employee_data(ldap_uid, "campus-uid")
    end

    def fetch_employee_data_with_employee_id(employee_id)
      fetch_employee_data(employee_id, "hr-employee-id")
    end

    def fetch_employee_data(id, id_type)
      if [app_id, app_key, endpoint].any?(&:blank?)
        Rails.logger.warn missing_api_values_message
        return nil
      end
      response =
        Faraday.get("#{endpoint}/employees/#{id}") do |req|
          req.params["id-type"] = id_type
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

