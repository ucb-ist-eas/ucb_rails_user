module UcbRailsUser::AuthConcerns
  extend ActiveSupport::Concern

  included do
    rescue_from UcbRailsUser::LdapPerson::Finder::BlankSearchTermsError do
      render :js => %(alert("Enter search terms"))
    end

    before_action :ensure_authenticated_user
    before_action :log_request

    after_action  :remove_user_settings

    helper_method :superuser?, :current_ldap_person, :current_user, :logged_in?, :logged_in_user
  end

  def superuser?
    current_user.try(:superuser?)
  end

  def logged_in_user
    @logged_in_user ||= begin
      logger.debug 'recalc of logged_in_user'
      user_session_manager&.current_user(session[:uid])
    end
  end

  def current_user
    logged_in_user&.impersonation_target || logged_in_user
  end

  # Returns +true+ if there is a logged in user
  #
  # @return [true] if user logged in
  # @return [false] if user not logged in
  def logged_in?
    logged_in_user.present?
  end

  def log_request
    UcbRailsUser::UserSessionManager::Base.current_user = current_user
    user_session_manager.log_request(current_user)
  end

  def remove_user_settings
    UcbRailsUser::UserSessionManager::Base.current_user = nil
  end

  # Returns an instance of UCB::LDAP::Person if there is a logged in user
  #
  # @return [UCB::LDAP::Person] if user logged in
  # @return [nil] if user not logged in
  def current_ldap_person
    if logged_in?
      @current_ldap_person ||= begin
        logger.debug 'recalc of current_ldap_person'
        user_session_manager.people_ou_entry(session[:uid])
      end
    end
  end

  def ensure_admin_user
    superuser? or not_authorized!
  end

  # Before filter that redirects redirects to +login_url+ unless user is logged in
  #
  # @return [nil]
  def ensure_authenticated_user
    unless session.has_key?(:uid)
      session[:original_url] = request.env['REQUEST_URI']
      redirect_to login_url
    end
  end

  def user_session_manager
    @user_session_manager ||= begin
      logger.debug "creating new user_session_manager"
      klass = UcbRailsUser[:user_session_manager] || UcbRailsUser::UserSessionManager::ActiveInUserTable
      klass.to_s.classify.constantize.new
    end
  rescue NameError
    raise "Could not find UcbRailsUser user_session_manager: #{klass}"
  end

  def not_authorized!
    render plain: "Not Authorized", status: 401
    return false
  end

  def not_authorized_unless(condition)
    unless condition
      not_authorized!
    end
  end
end
