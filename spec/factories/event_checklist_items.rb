FactoryBot.define do
  factory :event_checklist_item do
    association :event_checklist
    event { event_checklist.event }
    association :assignee, factory: :user

    sequence(:title) { |n| "Checklist item #{n}" }
    due_at { 2.days.from_now }
    completed { false }
  end
end
