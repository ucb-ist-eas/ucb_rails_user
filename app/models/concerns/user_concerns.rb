module UserConcerns
  extend ActiveSupport::Concern

  # Overridden by application
  def roles
    []
  end

  def has_role?(role)
    superuser? || roles.include?(role)
  end

  def active?
    !inactive?
  end

  def inactive?
    inactive_flag
  end

  def superuser!(_superuser=true)
    update_attribute(:superuser_flag, _superuser)
  end

  def superuser?
    superuser_flag
  end

  def inactive!(_inactive=true)
    update_attribute(:inactive_flag, _inactive)
  end

  def ldap_entry
    UcbRailsUser::LdapPerson::Finder.find_by_uid!(uid)
  end

  def full_name
    return nil unless first_name || last_name
    "#{first_name} #{last_name}".strip
  end

  class_methods do
    def active
      where(inactive_flag: false)
    end

    def superuser
      where(superuser_flag: true)
    end
  end

end

