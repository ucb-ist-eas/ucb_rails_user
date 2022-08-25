module UcbRailsUser
  class ImpersonationsController < ApplicationController
    include UcbRailsUser::Concerns::ImpersonationsController

    # Don't add anything more here - any logic for this controller should go into
    # Concerns::ImpersonationsController. This will make it much easier for host apps to customize
    # behavior if they need to
    # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern
  end
end
