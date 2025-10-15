require "rails_helper"

RSpec.describe CommentPolicy do
  subject(:policy) { described_class.new(user, comment) }

  let(:event) { create(:event, visibility: visibility) }
  let(:comment_author) { create(:user) }
  let(:comment) { create(:comment, event:, user: comment_author) }
  let(:visibility) { "private" }

  context "when user is not present" do
    let(:user) { nil }

    it { is_expected.not_to permit_actions([:create, :destroy]) }

    context "when event is public" do
      let(:visibility) { "public" }

      it "allows viewing" do
        expect(policy.show?).to be(true)
      end
    end
  end

  context "when user can view the event" do
    let(:user) { create(:user) }

    before do
      comment.event.update!(visibility: "public")
    end

    it "allows creating" do
      expect(policy.create?).to be(true)
    end

    it "allows destroy for author" do
      policy = described_class.new(comment_author, comment)
      expect(policy.destroy?).to be(true)
    end

    it "allows destroy for event owner" do
      policy = described_class.new(comment.event.user, comment)
      expect(policy.destroy?).to be(true)
    end
  end
end
