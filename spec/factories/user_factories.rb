FactoryBot.define do
  factory :user, class: UcbRailsUser::User do
    ldap_uid { Faker::Number.unique.number(digits: 8).to_s }
    employee_id { Faker::Number.unique.number(digits: 8).to_s }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }

    factory :superuser do
      superuser_flag { true }
    end

    factory :super_app_admin do
      super_app_admin_flag { true }
    end

    factory :super_department_admin do
      super_department_admin_flag { true }
    end
  end
end

