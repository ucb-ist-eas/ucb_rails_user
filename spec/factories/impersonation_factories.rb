FactoryBot.define do

  factory :impersonation, class: UcbRailsUser::Impersonation do
    user { create(:user) }
    target { create(:user) }
    active { false }
  end

end
