FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    first_name { "Test" }
    last_name { "User" }
    birthday { Date.new(1990, 1, 1) }
    sequence(:tag) { |n| "tag-#{n}" }
    sequence(:username) { |n| "test_user_#{n}" }
    confirmed_at { Time.current }
    association :plan

    before(:create) do
      Role.find_or_create_by!(key: "member") do |role|
        role.name = "Member"
        role.description = "Default member role"
      end
    end

    trait :admin do
      after(:create) do |user|
        Role.find_or_create_by!(key: "admin") do |role|
          role.name = "Administrator"
          role.description = "Full access to the platform"
        end
        user.grant_role!(:admin)
        user.reload
      end
    end
  end
end
