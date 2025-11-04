# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Share::Events", type: :request do
  describe "GET /share/events/:token" do
    it "responds with success and increments share views" do
      event = create(:event, share_views: 0)

      expect do
        get share_event_path(event.share_token)
      end.to change { event.reload.share_views }.by(1)

      expect(response).to be_successful
    end
  end

  describe "POST /share/events/:token/track" do
    it "returns ok and increments share clicks" do
      event = create(:event, share_clicks: 0)

      expect do
        post share_event_track_path(event.share_token)
      end.to change { event.reload.share_clicks }.by(1)

      expect(response).to have_http_status(:ok)
      expect(response.body).to be_blank
    end

    it "returns not found for an invalid token" do
      post share_event_track_path("missing-token")

      expect(response).to have_http_status(:not_found)
    end
  end
end
