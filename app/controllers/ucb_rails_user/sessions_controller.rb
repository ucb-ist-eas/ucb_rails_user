# Manages starting and ending of sessions, i.e., logging in and out.
class UcbRailsUser::SessionsController < ApplicationController
  include UcbRailsUser::Concerns::SessionsController

  # Don't add anything more here - any logic for this class should go into
  # Concerns::SessionsController. This will make it much easier for host
  # apps to customize behavior if they need to
  # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern
end
