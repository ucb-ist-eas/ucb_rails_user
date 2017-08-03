require "ucb_rails_user/engine"

require "haml"
require "haml-rails"
require "sass-rails"
require "omniauth"
require "omniauth-cas"
require "ucb_ldap"
require "active_attr"

require "bootstrap-view-helpers"
#require "rails_view_helpers"

module UcbRailsUser

  def self.logger
    Rails.logger
  end

end

