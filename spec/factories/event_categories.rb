FactoryBot.define do
  factory :event_category do
    sequence(:name) { |n| "Category #{n}" }
    emoji { ":event:" }
    description { "Factory-generated category" }
  end
end
