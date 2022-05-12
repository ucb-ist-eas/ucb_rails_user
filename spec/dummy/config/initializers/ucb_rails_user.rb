require "ucb_rails_user/configuration/email"
require "ucb_rails_user/configuration/exception_notification"
require "ucb_rails_user/configuration/ldap"
require "ucb_rails_user/configuration/cas"
############################################################
# Load configuration from config/credentials.yml.enc
############################################################

credentials = Rails.application.credentials

############################################################
# ActionMailer
############################################################

UcbRailsUser::Configuration::Email.configure(credentials.email&.with_indifferent_access())

############################################################
# Exception Notification
############################################################

#UcbRailsUser::Configuration::ExceptionNotification.configure(config.for('exception_notification'))

############################################################
# UCB::LDAP
############################################################

UcbRailsUser::Configuration::Ldap.configure(credentials.ldap&.with_indifferent_access())

############################################################
# OmniAuth
############################################################

UcbRailsUser::Configuration::Cas.configure(credentials.cas&.with_indifferent_access())

############################################################
# UcbRails
############################################################

UcbRailsUser.config do |config|

  #########################################################
  # manage login authorization, current user, etc.
  #########################################################

  # config.user_session_manager = "UcbRailsUser::UserSessionManager::InPeopleOu"
  # KEEP THIS NEXT ONE
  config.user_session_manager = "UcbRailsUser::UserSessionManager::InPeopleOuAddToUsersTable"
  # config.user_session_manager = "UcbRailsUser::UserSessionManager::ActiveInUserTable"
  # config.user_session_manager = "UcbRailsUser::UserSessionManager::AdminInUserTable"

  #########################################################
  # omniauth authentication provider
  #########################################################

  config.omniauth_provider = :cas        # goes to CalNet
  # config.omniauth_provider = :developer  # Users test ldap entries

end
