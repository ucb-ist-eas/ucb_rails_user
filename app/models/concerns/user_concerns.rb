module UserConcerns
  extend ActiveSupport::Concern

  included do
    has_many :impersonations, class_name: "::UcbRailsUser::Impersonation", dependent: :delete_all
  end

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

  def can_impersonate?
    superuser?
  end

  # target can be a User instance or a user id
  # return true if Impersonation succeeded; false otherwise
  def impersonate!(target)
    target_id =
      if target.respond_to?(:id)
        target.id
      else
        User.find_by(id: target)&.id
      end
    return false unless impersonation_is_valid?(target_id)
    @current_impersonation = create_impersonation(target_id)
    @current_impersonation.present?
  end

  def current_impersonation
    return @current_impersonation if defined?(@current_impersonation)
    @current_impersonation = UcbRailsUser::Impersonation.find_by(user_id: self.id, active: true)
  end

  def impersonation_target
    current_impersonation&.target
  end

  def impersonating?
    current_impersonation.present?
  end

  def stop_impersonation!
    impersonations.update_all(active: false)
    @current_impersonation = nil
  end

  def recent_impersonations(max=25)
    @recent_impersonations ||=
      impersonations
        .uniq(&:target_id)
        .reject(&:active)
        .sort_by(&:created_at)
        .reverse
        .take(max)
  end

  private

  def impersonation_is_valid?(target_id)
    target_id.present? &&
      can_impersonate? &&
      target_id != self.id
  end

  def create_impersonation(target_id)
    new_impersonation =
      UcbRailsUser::Impersonation.transaction do
        # make sure any other impersonations are cleared out
        impersonations.update_all(active: false)
        UcbRailsUser::Impersonation.create!(user_id: self.id, target_id: target_id, active: true)
      end
    if new_impersonation.present? && !new_impersonation.new_record?
      new_impersonation
    else
      nil
    end
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

