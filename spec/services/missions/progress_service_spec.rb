require "rails_helper"

RSpec.describe Missions::ProgressService do
  let(:user) { create(:user) }
  let!(:mission) { create(:mission, key: "weekend_host", target_value: 1, reward_xp: 25) }

  it "assigns and completes mission" do
    service = described_class.new(user)

    expect do
      service.tick!(:weekend_host)
    end.to change(UserMission, :count).by(1)

    assignment = user.user_missions.last
    expect(assignment).to be_completed
    expect(user.reload.xp).to eq(25)
  end
end
