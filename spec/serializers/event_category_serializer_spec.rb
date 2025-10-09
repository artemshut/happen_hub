require "rails_helper"

RSpec.describe EventCategorySerializer do
  it "serializes the expected attributes" do
    category = build(:event_category, id: 42, name: "Music", emoji: "🎵", description: "Concerts")

    serialized = described_class.new(category).serializable_hash
    data = serialized[:data]

    expect(data[:id]).to eq("42")
    expect(data[:attributes]).to include(
      name: "Music",
      emoji: "🎵",
      description: "Concerts"
    )
  end
end
