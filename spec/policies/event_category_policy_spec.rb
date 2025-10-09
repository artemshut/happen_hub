require "rails_helper"

RSpec.describe EventCategoryPolicy do
  subject(:policy) { described_class.new(user, event_category) }

  let(:event_category) { build(:event_category) }

  context "when user is nil" do
    let(:user) { nil }

    it "allows index access" do
      expect(described_class::Scope.new(user, EventCategory.all).resolve).to eq(EventCategory.all)
    end

    it "allows show access" do
      expect(policy.show?).to be(true)
    end

    it "disallows write actions" do
      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end

  context "when user is present" do
    let(:user) { build(:user) }

    it "allows read access" do
      expect(policy.index?).to be(true)
      expect(policy.show?).to be(true)
    end

    it "still prevents write access" do
      expect(policy.create?).to be(false)
      expect(policy.update?).to be(false)
      expect(policy.destroy?).to be(false)
    end
  end
end
