FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "Role #{n}" }
    sequence(:key) { |n| "role_#{n}" }
    description { "Auto-generated role" }
  end
end
