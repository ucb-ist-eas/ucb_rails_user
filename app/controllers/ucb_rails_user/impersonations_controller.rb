class UcbRailsUser::ImpersonationsController < ApplicationController
  include UcbRailsUser::ImpersonationsControllerConcerns

  # Don't add anything more here - any logic for this controller should go into
  # UcbRiailsUser::ImpersonationsControllerConcerns. This will make it much easier for host apps to customize
  # behavior if they need to
  # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern
end
