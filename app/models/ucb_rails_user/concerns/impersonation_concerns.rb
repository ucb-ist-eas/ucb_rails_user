module UcbRailsUser::Concerns::ImpersonationConcerns
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    belongs_to :target, class_name: 'User'
  end
end
