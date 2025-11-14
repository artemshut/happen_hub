require "rails_helper"

RSpec.describe "API V1 Plans", type: :request do
  describe "GET /api/v1/plans" do
    let!(:low_priority_plan) { create(:plan, name: "Starter", priority: 1) }
    let!(:high_priority_plan) { create(:plan, name: "Galaxy", priority: 3) }

    it "returns the available plans ordered for display" do
      get api_v1_plans_path

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body.fetch("data").size).to eq(2)
      expect(body["data"].first.dig("attributes", "name")).to eq("Galaxy")
      expect(body["data"].last.dig("attributes", "name")).to eq("Starter")
    end

    it "flags the current user plan when a token is passed" do
      user = create(:user, plan: high_priority_plan)
      token = JwtService.encode(user_id: user.id)

      get api_v1_plans_path, headers: { "Authorization" => "Bearer #{token}" }

      body = JSON.parse(response.body)
      current_plan = body["data"].detect { |plan| plan.dig("attributes", "is_current_plan") }
      expect(current_plan).to be_present
      expect(current_plan.dig("attributes", "name")).to eq("Galaxy")
    end
  end
end
