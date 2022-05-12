class UcbRailsUser::Impersonation < ApplicationRecord
  include UcbRailsUser::Concerns::ImpersonationConcerns

  # Don't add anything more here - any logic for the Impersonation class should go into
  # ImpersonationConcerns. This will make it much easier for host apps to customize
  # behavior if they need to
  # http://guides.rubyonrails.org/engines.html#implementing-decorator-pattern-using-activesupport-concern

end
