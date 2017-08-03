module UcbRailsUser
  module UserSessionManager

    class InPeopleOuAddToUsersTable < ActiveInUserTable

      def login(uid)
        self.uid = uid

        if people_ou_entry.present?
          UcbRailsUser::UserLdapService.create_or_update_user_from_entry(people_ou_entry).tap do |user|
            user.touch(:last_login_at)
          end
        else
          nil
        end
      end

    end

  end
end
