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

  it "exposes xp and cosmetic unlocks" do
    user = create(:user, xp: 420, cosmetic_unlocks: { "badges" => [ "soundcheck-pro" ] })

    serialized = described_class.new(user).serializable_hash[:data][:attributes]

    expect(serialized[:xp]).to eq(420)
    expect(serialized[:cosmetic_unlocks]).to eq({ "badges" => [ "soundcheck-pro" ] })
  end

  it "exposes the mobile profile payload" do
    unlocks = {
      "badges" => [ "soundcheck-pro", "night-owl" ],
      "themes" => [ "neon" ],
      "theme_flags" => { "sparkle" => true }
    }
    user = create(:user, username: "profile_handle", theme_preference: "dark", cosmetic_unlocks: unlocks)

    attributes = described_class.new(user).serializable_hash[:data][:attributes]

    expect(attributes[:handle]).to eq("profile_handle")
    expect(attributes[:badges]).to eq([ "soundcheck-pro", "night-owl" ])
    expect(attributes[:theme_settings]).to eq(
      preference: "dark",
      unlocked_themes: [ "neon" ],
      flags: { "sparkle" => true }
    )
    expect(attributes[:updated_at]).to be_present
  end
end
