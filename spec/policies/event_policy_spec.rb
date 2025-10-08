require "rails_helper"

RSpec.describe EventPolicy do
  subject(:policy) { described_class.new(policy_user, event) }

  let!(:member_role) { create(:role, key: "member", name: "Member") }
  let!(:admin_role) { create(:role, key: "admin", name: "Administrator") }

  let(:owner) { create(:user) }
  let(:category) { create(:event_category, name: "Testing") }
  let(:event) { create(:event, user: owner, event_category: category, visibility: "private") }

  before do
    allow_any_instance_of(Event).to receive(:schedule_reminders!).and_return(true)
    event
    create(:event_participation, event:, user: owner, rsvp_status: "maybe")
  end

  describe "management permissions" do
    context "when the policy user owns the event" do
      let(:policy_user) { owner }

      it "allows full management of the event" do
        aggregate_failures do
          expect(policy.update?).to be true
          expect(policy.destroy?).to be true
          expect(policy.invite_group?).to be true
          expect(policy.add_friend?).to be true
          expect(policy.remove_file?).to be true
        end
      end
    end

    context "when the policy user is an admin" do
      let(:policy_user) { create(:user, :admin) }

      it "allows management actions" do
        aggregate_failures do
          expect(policy.update?).to be true
          expect(policy.add_friend?).to be true
        end
      end
    end
  end

  describe "participation-specific permissions" do
    let(:policy_user) { create(:user) }

    before do
      create(:event_participation, event:, user: policy_user, rsvp_status: "pending")
    end

    it "allows RSVP updates but not broader management" do
      expect(policy.update_rsvp?).to be true
      expect(policy.update?).to be false
    end
  end

  describe "visibility for friends" do
    let(:policy_user) { create(:user) }

    before do
      event.update!(visibility: "friends")
      create(:friendship, user: owner, friend: policy_user, status: "accepted")
    end

    it "allows friends to view friends-only events" do
      expect(policy.show?).to be true
    end
  end

  describe EventPolicy::Scope do
    let(:policy_user) { owner }

    it "returns events accessible to the user" do
      scoped_events = described_class.new(policy_user, Event.all).resolve
      expect(scoped_events).to include(event)
    end
  end
end
