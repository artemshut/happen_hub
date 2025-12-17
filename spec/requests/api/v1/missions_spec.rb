require "rails_helper"

RSpec.describe "API V1 Missions", type: :request do
  let(:user) { create(:user) }
  let!(:mission) { create(:mission, key: "weekend_host", reward_xp: 50) }
  let!(:user_mission) { create(:user_mission, user:, mission:, target_value: 1) }
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer test"
    }
  end

  before do
    allow(JwtService).to receive(:decode).and_return({ user_id: user.id })
  end

  it "returns user missions" do
    get api_v1_missions_path, headers: headers
    expect(response).to have_http_status(:ok)
    json = JSON.parse(response.body)
    expect(json["data"].length).to eq(1)
    expect(json["data"].first["attributes"]["status"]).to eq("pending")
  end
end
