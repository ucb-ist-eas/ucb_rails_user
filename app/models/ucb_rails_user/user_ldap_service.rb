class UcbRailsUser::UserLdapService

  class << self

    def create_user_from_uid(uid)
      UcbRailsUser.logger.debug "create_user_from_uid #{uid}"

      ldap_entry = UcbRailsUser::LdapPerson::Finder.find_by_uid!(uid)
      create_user_from_ldap_entry(ldap_entry)
    end

    def create_user_from_ldap_entry(ldap_entry)
      UcbRailsUser.logger.debug "create_user_from_ldap_entry #{ldap_entry.uid}"

      UcbRailsUser.user_class.create! do |u|
        u.ldap_uid = ldap_entry.uid
        u.employee_id = ldap_entry.employee_id
        u.affiliate_id = ldap_entry.affiliate_id
        u.student_id = ldap_entry.student_id
        u.first_name = ldap_entry.first_name
        u.last_name = ldap_entry.last_name
        u.email = ldap_entry.email
        u.inactive_flag = ldap_entry.inactive
      end
    end

    def update_user_from_uid(uid)
      UcbRailsUser.logger.debug "update_user_from_uid #{uid}"

      ldap_entry = UcbRailsUser::LdapPerson::Finder.find_by_uid!(uid)
      update_user_from_ldap_entry(ldap_entry)
    end

    def update_user_from_ldap_entry(ldap_entry)
      UcbRailsUser.logger.debug "update_user_from_ldap_entry #{ldap_entry.uid}"

      UcbRailsUser.user_class.find_by_ldap_uid!(ldap_entry.uid).tap do |user|
        user.employee_id = ldap_entry.employee_id if user.respond_to?(:employee_id=)
        user.affiliate_id = ldap_entry.affiliate_id
        user.student_id = ldap_entry.student_id
        user.first_name = ldap_entry.first_name
        user.last_name = ldap_entry.last_name
        user.email = ldap_entry.email
        user.inactive_flag = ldap_entry.inactive
        user.save(validate: false)
      end
    end

    def create_or_update_user(uid)
      if user = UcbRailsUser.user_class.find_by_ldap_uid(uid)
        update_user_from_uid(uid)
      else
        create_user_from_uid(uid)
      end
    end

    def create_or_update_user_from_entry(entry)
      # LDAP returns some values as Net::BER::BerIdentifiedString instances, and not
      # all DBs seem to handle that well (e.g. Oracle) - we might want to fix LDAP library
      # to smooth this over?
      if user = UcbRailsUser.user_class.find_by_ldap_uid(entry.uid.to_s)
        update_user_from_ldap_entry(entry)
      else
        create_user_from_ldap_entry(entry)
      end
    end
  end
end
