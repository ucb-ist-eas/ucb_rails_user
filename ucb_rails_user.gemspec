$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ucb_rails_user/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ucb_rails_user"
  s.version     = UcbRailsUser::VERSION
  s.authors     = ["Steve Downey", "Peter Philips", "Tyler Minard", "Darin Wilson"]
  s.email       = ["darinwilson@gmail.com"]
  s.homepage    = "https://github.com/ucb-ist-eas/ucb_rails_user"
  s.summary     = "Rails engine for UCB user accounts"
  s.description = "Rails engine for managing user accounts within UC Berkeley's auth system"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "> 5.0"

  s.add_dependency "haml", "~> 5.0"
  s.add_dependency "haml-rails", "~> 2.0"
  s.add_dependency "active_attr", "~> 0.10"
  s.add_dependency "simple_form"

  s.add_dependency "omniauth", "~> 1.8"
  s.add_dependency "omniauth-cas", "~> 1.1"

  s.add_dependency "ucb_ldap", "~> 3.0"

  s.add_development_dependency "puma", "~> 5.3"
  s.add_development_dependency "sqlite3", "~> 1.3", '< 1.4'
  s.add_development_dependency "rspec-rails", "~> 3.5"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "faker"
  s.add_development_dependency "capybara", "~> 3.0"
  s.add_development_dependency "capybara-screenshot"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "chromedriver-helper"
end
