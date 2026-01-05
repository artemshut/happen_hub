FactoryBot.define do
  factory :event_checklist do
    association :event
    sequence(:title) { |n| "Checklist #{n}" }
  end
end
