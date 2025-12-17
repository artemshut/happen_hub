require "rails_helper"

RSpec.describe UserMission, type: :model do
  let(:user) { create(:user) }
  let(:mission) { create(:mission, target_value: 2, reward_xp: 50) }

  it "increments progress and completes" do
    assignment = described_class.create!(user:, mission:, target_value: 2)

    expect {
      assignment.increment!(1)
    }.to change { assignment.reload.progress }.from(0).to(1)

    expect(assignment).to be_in_progress

    expect {
      assignment.increment!(1)
    }.to change { assignment.reload.status }.from("in_progress").to("completed")
  end

  it "does not double reward once completed" do
    assignment = described_class.create!(user:, mission:, target_value: 1)
    expect_any_instance_of(Missions::RewardService).to receive(:apply_rewards!).once.and_call_original
    assignment.increment!(1)
    assignment.increment!(1)
  end
end
