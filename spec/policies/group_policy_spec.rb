require "rails_helper"

RSpec.describe GroupPolicy do
  subject(:policy) { described_class.new(user, group) }

  let(:group) { create(:group) }
  let!(:member) { create(:user) }

  before do
    group.members << member
  end

  context "when user is nil" do
    let(:user) { nil }

    it "denies index" do
      expect(described_class::Scope.new(user, Group.all).resolve).to be_empty
    end

    it "denies all actions" do
      expect(policy.index?).to be(false)
      expect(policy.show?).to be(false)
      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end

  context "when user is group creator" do
    let(:user) { group.creator }

    it "allows management actions" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
      expect(policy.create?).to be(true)
      expect(policy.update?).to be(true)
      expect(policy.destroy?).to be(true)
    end

    it "includes group in scope" do
      scoped = described_class::Scope.new(user, Group.all).resolve
      expect(scoped).to include(group)
    end
  end

  context "when user is a member but not creator" do
    let(:user) { member }

    it "allows read-only actions" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
    end

    it "prevents destructive actions" do
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end

    it "includes group in scope" do
      expect(described_class::Scope.new(user, Group.all).resolve).to include(group)
    end
  end
end
