module UcbRailsUser
  class HomeController < ApplicationController
    include UcbRailsUser::Concerns::ControllerMethods
    include UcbRailsUser::Concerns::HomeController

    # Don't add anything more here - any logic for this class should go into
    # Concerns::HomeController. This will make it much easier for host
    # apps to customize behavior if they need to
    # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern
  end
end

