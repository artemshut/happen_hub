FactoryBot.define do
  factory :user_mission do
    association :user
    association :mission
    status { :pending }
    progress { 0 }
    target_value { mission&.target_value || 1 }
  end
end
