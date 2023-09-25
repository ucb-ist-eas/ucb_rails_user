require "ucb_rails_user/engine"

require "haml"
require "haml-rails"
require "omniauth"
require "omniauth-cas"
require "ucb_ldap"
require "active_attr"

module UcbRailsUser

  mattr_accessor :user_class

  def self.logger
    Rails.logger
  end

  def self.user_class
    @@user_class&.constantize || ::User
  end

end
