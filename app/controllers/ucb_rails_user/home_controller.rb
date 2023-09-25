class UcbRailsUser::HomeController < ApplicationController
  include UcbRailsUser::AuthConcerns
  include UcbRailsUser::HomeControllerConcerns

  # Don't add anything more here - any logic for this class should go into
  # UcbRailsUser::HomeControllerConcerns. This will make it much easier for host
  # apps to customize behavior if they need to
  # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern
end
