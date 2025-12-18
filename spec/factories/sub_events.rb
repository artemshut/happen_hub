FactoryBot.define do
  factory :sub_event do
    association :event
    sequence(:title) { |n| "Segment #{n}" }
    start_time { Time.current }
    end_time { Time.current + 1.hour }
    location { "Studio #{rand(100)}" }
    notes { "Bring instruments" }
    position { 0 }
  end
end
