module UcbRailsUser
  module UserSessionManager
    class ActiveInUserTable < Base

      def login(uid)
        self.uid = uid

        if user_table_entry && people_ou_entry
          UcbRailsUser::UserLdapService.update_user_from_ldap_entry(people_ou_entry).tap do |user|
            user.touch(:last_login_at)
          end
        else
          false
        end
      end

      def current_user(uid)
        User.find_by_ldap_uid(uid)
      end

      private

      def user_table_entry
        active_user
      end

    end
  end
end
