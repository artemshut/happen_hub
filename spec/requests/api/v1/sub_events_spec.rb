require "rails_helper"

RSpec.describe "API V1 SubEvents", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event, user:) }
  let(:sub_event) { create(:sub_event, event:, title: "Soundcheck") }
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer token"
    }
  end

  before do
    allow(JwtService).to receive(:decode).and_return({ user_id: user.id })
  end

  describe "GET /api/v1/events/:event_id/sub_events" do
    it "returns sub-events" do
      sub_event
      get api_v1_event_sub_events_path(event), headers: headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].size).to eq(1)
      expect(json["data"].first["attributes"]["title"]).to eq("Soundcheck")
    end
  end

  describe "POST /api/v1/events/:event_id/sub_events" do
    it "creates a sub-event" do
      post api_v1_event_sub_events_path(event), headers: headers, params: {
        sub_event: { title: "Warm-up", start_time: 1.hour.from_now }
      }

      expect(response).to have_http_status(:created)
      expect(event.sub_events.count).to eq(1)
    end
  end

  describe "PATCH /api/v1/events/:event_id/sub_events/:id" do
    it "updates a sub-event" do
      patch api_v1_event_sub_event_path(event, sub_event), headers: headers, params: {
        sub_event: { title: "Updated" }
      }

      expect(response).to have_http_status(:ok)
      expect(sub_event.reload.title).to eq("Updated")
    end
  end

  describe "DELETE /api/v1/events/:event_id/sub_events/:id" do
    it "removes a sub-event" do
      delete api_v1_event_sub_event_path(event, sub_event), headers: headers
      expect(response).to have_http_status(:no_content)
      expect(event.sub_events.count).to eq(0)
    end
  end
end
