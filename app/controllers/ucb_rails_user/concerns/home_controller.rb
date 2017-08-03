module UcbRailsUser::Concerns::HomeController
  extend ActiveSupport::Concern

  included do
    skip_before_action :ensure_authenticated_user
  end

  def index
    if logged_in?
      render "logged_in"
    else
      render "not_logged_in"
    end
  end

end

