FactoryBot.define do
  factory :comment do
    association :event
    association :user
    content { "Test comment" }
  end
end
