module UcbRailsUser::HomeControllerConcerns
  extend ActiveSupport::Concern

  included do
    skip_before_action :ensure_authenticated_user, raise: false
  end

  def index
    if logged_in?
      render "logged_in"
    else
      render "not_logged_in"
    end
  end

end
