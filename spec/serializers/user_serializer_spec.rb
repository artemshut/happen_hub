require "rails_helper"

RSpec.describe UserSerializer do
  it "includes plan information and counters" do
    plan = create(:plan, max_active_events: 5, features: [ "RSVP tracking" ])
    user = create(:user, plan: plan)

    serialized = described_class.new(user).serializable_hash
    plan_data = serialized[:data][:attributes][:plan]

    expect(plan_data[:name]).to eq(plan.name)
    expect(plan_data[:features]).to eq([ "RSVP tracking" ])
    expect(plan_data[:max_active_events]).to eq(5)
    expect(plan_data[:unlimited_events]).to be(false)
  end
end
