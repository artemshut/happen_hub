FactoryBot.define do
  factory :mission do
    sequence(:key) { |n| "mission_#{n}" }
    title { "Mission ##{key}" }
    description { "Complete the mission" }
    category { "weekend" }
    target_value { 1 }
    reward_xp { 100 }
    reward_badge { nil }
    auto_assign { true }
    active { true }
  end
end
