FactoryBot.define do
  factory :plan do
    sequence(:name) { |n| "Plan #{n}" }
    sequence(:key) { |n| "plan_#{n}" }
    tagline { "Test plan" }
    monthly_price_cents { 0 }
    annual_price_cents { 0 }
    max_active_events { 3 }
    highlighted { false }
    priority { 1 }
    features { [ "Test feature" ] }
  end
end
