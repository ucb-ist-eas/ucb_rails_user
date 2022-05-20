# Session manager that attempts to pull the user record from UCPath, and
# falls back to LDAP if needed

module UcbRailsUser
  module UserSessionManager

    class InUcPathAddToUsersTable < ActiveInUserTable
      def login(uid)
        self.uid = uid

        # try UCPath first
        user = safely_load_user_from_api do
          UcbRailsUser::UserUcPathService.create_or_update_user_from_ldap_uid(self.uid)
        end

        # if that doesn't work, try LDAP
        user ||= safely_load_user_from_api do
          UcbRailsUser::UserLdapService.create_or_update_user_from_entry(people_ou_entry)
        end

        user&.tap do |u|
          u&.touch(:last_login_at)
        end
      end

      private

      def safely_load_user_from_api(&block)
        begin
          user = block.call
        rescue StandardError
          user = nil
        end
        user
      end
    end

  end
end
