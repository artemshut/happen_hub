require "rails_helper"

RSpec.describe "API V1 Event checklists", type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event, user:) }
  let!(:checklist) { create(:event_checklist, event:, title: "Logistics") }
  let!(:checklist_item) { create(:event_checklist_item, event:, event_checklist: checklist, title: "Lock venue") }
  let(:headers) do
    {
      "ACCEPT" => "application/json",
      "Authorization" => "Bearer token"
    }
  end

  before do
    allow(JwtService).to receive(:decode).and_return({ user_id: user.id })
  end

  describe "GET /api/v1/events/:event_id/checklists" do
    it "returns checklists with items" do
      get api_v1_event_checklists_path(event), headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].first["attributes"]["title"]).to eq("Logistics")
      expect(json["data"].first.dig("relationships", "items", "data").size).to eq(1)
    end
  end

  describe "POST /api/v1/events/:event_id/checklists" do
    it "creates a checklist" do
      post api_v1_event_checklists_path(event), headers: headers, params: {
        event_checklist: { title: "Hospitality" }
      }

      expect(response).to have_http_status(:created)
      expect(event.checklists.count).to eq(2)
    end
  end

  describe "PATCH /api/v1/events/:event_id/checklists/:id" do
    it "updates checklist title" do
      patch api_v1_event_checklist_path(event, checklist), headers: headers, params: {
        event_checklist: { title: "Updated" }
      }

      expect(response).to have_http_status(:ok)
      expect(checklist.reload.title).to eq("Updated")
    end
  end

  describe "DELETE /api/v1/events/:event_id/checklists/:id" do
    it "removes the checklist" do
      delete api_v1_event_checklist_path(event, checklist), headers: headers
      expect(response).to have_http_status(:no_content)
      expect(event.checklists.count).to eq(0)
    end
  end

  describe "GET /api/v1/events/:event_id/checklists/:checklist_id/items" do
    it "returns checklist items" do
      get api_v1_event_checklist_items_path(event, checklist), headers: headers

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["data"].first["attributes"]["title"]).to eq("Lock venue")
    end

    it "forbids viewers without access" do
      stranger = create(:user)
      allow(JwtService).to receive(:decode).and_return({ user_id: stranger.id })

      get api_v1_event_checklist_items_path(event, checklist), headers: headers
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/events/:event_id/checklists/:checklist_id/items" do
    it "creates an item" do
      post api_v1_event_checklist_items_path(event, checklist), headers: headers, params: {
        event_checklist_item: { title: "Review menu" }
      }

      expect(response).to have_http_status(:created)
      expect(checklist.items.count).to eq(2)
    end
  end

  describe "PATCH /api/v1/events/:event_id/checklists/:checklist_id/items/:id" do
    it "updates the checklist item" do
      patch api_v1_event_checklist_item_path(event, checklist, checklist_item), headers: headers, params: {
        event_checklist_item: { title: "Lock venue ASAP" }
      }

      expect(response).to have_http_status(:ok)
      expect(checklist_item.reload.title).to eq("Lock venue ASAP")
    end
  end

  describe "PATCH /api/v1/events/:event_id/checklists/:checklist_id/items/:id/toggle_complete" do
    it "toggles completion" do
      patch toggle_complete_api_v1_event_checklist_item_path(event, checklist, checklist_item), headers: headers

      expect(response).to have_http_status(:ok)
      expect(checklist_item.reload).to be_completed
    end
  end

  describe "PATCH /api/v1/events/:event_id/checklists/:checklist_id/items/:id/reorder" do
    let!(:second_item) { create(:event_checklist_item, event:, event_checklist: checklist, title: "Dial in lights") }

    it "repositions the checklist item" do
      patch reorder_api_v1_event_checklist_item_path(event, checklist, second_item), headers: headers, params: { position: 1 }

      expect(response).to have_http_status(:ok)
      expect(checklist.items.first).to eq(second_item.reload)
    end
  end

  describe "DELETE /api/v1/events/:event_id/checklists/:checklist_id/items/:id" do
    it "removes the checklist item" do
      delete api_v1_event_checklist_item_path(event, checklist, checklist_item), headers: headers
      expect(response).to have_http_status(:no_content)
      expect(checklist.items.count).to eq(0)
    end
  end
end
