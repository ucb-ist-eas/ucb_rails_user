require "faraday"

module UcbRailsUser
  module UserSessionManager

    class InPeopleOuAddToUsersTableWithPreferredName < ActiveInUserTable

      def login(uid)
        self.uid = uid

        if people_ou_entry.present?
          UcbRailsUser::UserLdapService.create_or_update_user_from_entry(people_ou_entry).tap do |user|
            add_preferred_name!(user)
            user.touch(:last_login_at)
          end
        else
          nil
        end
      end

      private

      def add_preferred_name!(user)
        unless user.respond_to?(:preferred_first_name) and user.respond_to?(:preferred_last_name)
          Rails.logger.warn missing_columns_message
          return
        end

        raw_response = UcPathClient.new.fetch_employee_data(user.ldap_uid)
        unless raw_response.present?
          Rails.logger.warn "ucb_rails_user: unable to fetch preferred name from UCPath"
          return
        end

        if (preferred_name_hash = EmployeeDataParser.new(raw_response.body).get_preferred_name())
          user.update!(preferred_first_name: preferred_name_hash["givenName"],
                       preferred_last_name: preferred_name_hash["familyName"])
        end
      end

      def missing_columns_message
        message = <<~END_MSG.strip
          It looks like you're trying to use the preferred user name feature of
          ucb_rails_user, but your users table doesn't have the expected
          columns (preferred_first_name and preferred_last_name).
          To resolve this, install the new migrations into your host app:
              bin/rails railties:install:migrations
          then run migrations as usual.
        END_MSG
      end

    end

    class UcPathClient
      attr_reader :app_id, :app_key, :endpoint

      def initialize
        @app_id  = Rails.application.credentials.hcm&.fetch(:app_id)
        @app_key = Rails.application.credentials.hcm&.fetch(:app_key)
        @endpoint = Rails.application.credentials.hcm&.fetch(:endpoint)
      end

      def fetch_employee_data(ldap_uid)
        if [@app_id, @app_key, @endpoint].any?(&:blank?)
          Rails.logger.warn missing_api_values
          return nil
        end

        Faraday.get("#{endpoint}/employees/#{ldap_uid}") do |req|
          req.params["id-type"] = "campus-uid"
          req.headers["Accept"] = "application/json"
          req.headers["app_id"] = app_id
          req.headers["app_key"] = app_key
        end
      end

      private

      def missing_api_values
        message = <<~END_MSG.strip
          It looks like you're trying to use the preferred user name feature of
          ucb_rails_user, but the host app has not provided all of the expected
          credentials to access the UCPath API.
          To resolve this, add an "hcm" section to the Rails credentials file of
          the host app, and provide values for app_id, app_key, and endpoint.
        END_MSG
      end
    end

    class EmployeeDataParser
      attr_reader :raw_response_data

      def initialize(raw_response_data)
        @raw_response_data = raw_response_data
      end

      def get_preferred_name
        parsed_data = JSON.parse(raw_response_data)
        response = parsed_data&.dig("response")&.first
        return nil unless response.present?
        response["names"]&.detect  { |n| n.dig("type", "code") == "PRI" }
      end
    end

  end
end
