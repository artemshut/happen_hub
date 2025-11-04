# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  describe "share token generation" do
    it "assigns a share token before validation when missing" do
      event = build(:event, share_token: nil)

      expect { event.valid? }.to change(event, :share_token).from(nil)
    end

    it "does not overwrite an existing share token" do
      event = build(:event, share_token: "preset-token")

      event.valid?

      expect(event.share_token).to eq("preset-token")
    end
  end

  describe "#share_url" do
    it "returns a fully qualified share URL for the provided host and protocol" do
      event = create(:event)

      url = event.share_url(host: "example.test", protocol: "http")

      expect(url).to eq("http://example.test/share/events/#{event.share_token}")
    end
  end

  describe "#increment_share_views!" do
    it "increments the persisted share views counter" do
      event = create(:event, share_views: 0)

      expect { event.increment_share_views! }.to change { event.reload.share_views }.by(1)
    end
  end

  describe "#increment_share_clicks!" do
    it "increments the persisted share clicks counter" do
      event = create(:event, share_clicks: 0)

      expect { event.increment_share_clicks! }.to change { event.reload.share_clicks }.by(1)
    end
  end
end
