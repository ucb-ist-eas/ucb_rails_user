module UcbRailsUser::Concerns::ImpersonationsController
  extend ActiveSupport::Concern

  included do
    before_action :check_permissions, except: [:stop_impersonation]
  end

  def index

  end

  def create
    target = UcbRailsUser::User.find_by(id: params[:ucb_rails_user_impersonation][:target_id])
    if logged_in_user.impersonate!(target)
      flash[:info] = "You are now impersonating #{target.full_name}"
      return redirect_to "/"
    else
      if target&.id == logged_in_user.id
        flash[:error] = "Sorry - you can't impersonate yourself."
      else
        flash[:error] = "Unable to start impersonating - please try again"
      end
      return redirect_to action: :index
    end
  end

  def stop_impersonation
    logged_in_user.stop_impersonation!
    flash[:info] = "You are no longer impersonating."
    redirect_to request.referer || "/"
  end

  private

  def check_permissions
    unless logged_in_user.can_impersonate?
      # TODO: I'm not crazy about this - should we provide some generic error pages for common situations?
      return render plain: "Not Authorized"
    end
  end

end

