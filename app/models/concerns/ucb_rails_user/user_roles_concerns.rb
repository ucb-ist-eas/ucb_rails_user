module UcbRailsUser::UserRolesConcerns
  extend ActiveSupport::Concern

  # Overridden by application
  def roles
    []
  end

  def has_role?(role)
    superuser? || roles.include?(role)
  end
end
