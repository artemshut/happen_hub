require "rails_helper"

RSpec.describe "API V1 Event Comments", type: :request do
  let(:user) { create(:user) }
  let(:event_owner) { create(:user) }
  let(:category) { create(:event_category) }
  let(:event) { create(:event, visibility: visibility, user: event_owner, event_category: category) }
  let(:headers) { { "Authorization" => "Bearer #{JwtService.encode(user_id: user.id)}" } }
  let(:visibility) { "private" }

  before do
    create(:friendship, user:, friend: event_owner, status: "accepted")
    create(:friendship, user: event_owner, friend: user, status: "accepted")
    create(:event_participation, event:, user:, rsvp_status: "accepted")
  end

  describe "GET /api/v1/events/:event_id/comments" do
    it "returns comments for a visible event" do
      create_list(:comment, 2, event:)

      get "/api/v1/events/#{event.id}/comments", headers: headers

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload.dig("data").length).to eq(2)
    end

    it "allows anonymous access to public events" do
      event.update!(visibility: "public")

      get "/api/v1/events/#{event.id}/comments"

      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /api/v1/events/:event_id/comments" do
    it "creates a comment" do
      expect do
        post "/api/v1/events/#{event.id}/comments",
             params: { comment: { content: "Hello" } }, headers: headers
      end.to change(Comment, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end

  describe "DELETE /api/v1/events/:event_id/comments/:id" do
    it "allows the author to delete" do
      comment = create(:comment, event:, user:)

      expect do
        delete "/api/v1/events/#{event.id}/comments/#{comment.id}", headers: headers
      end.to change(Comment, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
