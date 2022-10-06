module UcbRailsUser
  module UserSessionManager

    class InPeopleOuAddToUsersTable < ActiveInUserTable

      def login(uid)
        self.uid = uid

        if people_ou_entry.present?
          UcbRailsUser::UserLdapService.create_or_update_user_from_entry(people_ou_entry).tap do |user|
            if missing_or_invalid_email?(user)
              user.update(email: people_ou_entry.alternate_email) if people_ou_entry.alternate_email.present?
            end
            user.touch(:last_login_at)
          end
        else
          nil
        end
      end

      private

      def missing_or_invalid_email?(user)
        user&.email.blank? || (user.email =~ URI::MailTo::EMAIL_REGEXP).nil?
      end

    end

  end
end
