class ApplicationController < ActionController::Base
  include UcbRailsUser::AuthConcerns
  protect_from_forgery with: :exception
end
