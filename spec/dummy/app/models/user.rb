class User < ApplicationRecord
  include UcbRailsUser::Concerns::UserConcerns
end
