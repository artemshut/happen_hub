FactoryBot.define do
  factory :event_participation do
    association :event
    association :user
    rsvp_status { "pending" }
  end
end
