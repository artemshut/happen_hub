require "rails_helper"

RSpec.describe "API V1 Event Categories", type: :request do
  describe "GET /api/v1/event_categories" do
    it "returns a list of categories" do
      create_list(:event_category, 2)

      get "/api/v1/event_categories"

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload["data"]).to be_present
      expect(payload["data"].length).to eq(2)
    end
  end

  describe "GET /api/v1/event_categories/:id" do
    it "returns a single category" do
      category = create(:event_category)

      get "/api/v1/event_categories/#{category.id}"

      expect(response).to have_http_status(:ok)
      payload = JSON.parse(response.body)
      expect(payload.dig("data", "id")).to eq(category.id.to_s)
    end
  end
end
