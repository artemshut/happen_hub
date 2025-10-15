require "rails_helper"

RSpec.describe "API V1 Events participants", type: :request do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:stranger) { create(:user) }
  let(:category) { create(:event_category) }
  let(:headers) do
    token = JwtService.encode(user_id: user.id)
    { "Authorization" => "Bearer #{token}" }
  end

  before do
    create(:friendship, user: user, friend: friend, status: "accepted")
    create(:friendship, user: friend, friend: user, status: "accepted")
  end

  describe "GET /api/v1/events/:id for public event" do
    it "returns only friends in participants but counts everyone attending" do
      event = create(:event, visibility: "public", event_category: category, user: friend)
      create(:event_participation, event:, user: user, rsvp_status: "accepted")
      create(:event_participation, event:, user: friend, rsvp_status: "accepted")
      create(:event_participation, event:, user: stranger, rsvp_status: "accepted")

      get "/api/v1/events/#{event.id}", headers: headers

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      attributes = payload.dig("data", "attributes")

      expect(attributes["participant_count"]).to eq(3)

      participant_ids = attributes["participants"].map { |participant| participant["id"] }
      expect(participant_ids).to match_array([ user.id, friend.id ])
    end
  end

  describe "GET /api/v1/events/:id for private event" do
    it "returns all participants" do
      event = create(:event, visibility: "private", event_category: category, user: friend)
      create(:event_participation, event:, user: user, rsvp_status: "accepted")
      create(:event_participation, event:, user: friend, rsvp_status: "accepted")
      create(:event_participation, event:, user: stranger, rsvp_status: "maybe")

      get "/api/v1/events/#{event.id}", headers: headers

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      attributes = payload.dig("data", "attributes")

      expect(attributes["participant_count"]).to eq(3)
      participant_ids = attributes["participants"].map { |participant| participant["id"] }
      expect(participant_ids).to match_array([ user.id, friend.id, stranger.id ])
    end
  end
end
