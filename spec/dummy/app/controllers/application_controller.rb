class ApplicationController < ActionController::Base
  include UcbRailsUser::Concerns::ControllerMethods
  protect_from_forgery with: :exception
end
