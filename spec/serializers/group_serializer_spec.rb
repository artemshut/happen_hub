require "rails_helper"

RSpec.describe GroupSerializer do
  it "includes core attributes and members" do
    group = create(:group)
    member = create(:user)
    group.members << member unless group.members.include?(member)

    serialized = described_class.new(group, include: [ :members ]).serializable_hash
    data = serialized[:data]

    expect(data[:attributes]).to include(
      name: group.name,
      description: group.description
    )

    member_ids = serialized.dig(:included)&.map { |item| item[:id] }
    expect(member_ids).to include(member.id.to_s)
  end
end
