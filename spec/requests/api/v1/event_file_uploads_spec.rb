# frozen_string_literal: true

require "rails_helper"

RSpec.describe "API V1 Event file uploads", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:host) { create(:user) }
  let(:friend) { create(:user) }
  let(:category) { create(:event_category) }
  let(:headers) do
    token = JwtService.encode(user_id: host.id)
    { "Authorization" => "Bearer #{token}" }
  end
  let(:fixture_file) { fixture_file_upload("sample.txt", "text/plain") }

  before do
    create(:friendship, user: host, friend: friend, status: :accepted)
    create(:friendship, user: friend, friend: host, status: :accepted)
  end

  describe "POST /api/v1/events/:id/upload_files" do
    context "for a private event" do
      let(:event) { create(:event, visibility: :private, user: host, event_category: category) }

      it "allows the host to upload files" do
        expect do
          post upload_files_api_v1_event_path(event),
               headers: headers,
               params: { event: { files: [ fixture_file ] } }
        end.to change { event.reload.files.count }.by(1)

        expect(response).to have_http_status(:created)
        payload = JSON.parse(response.body)
        filenames = payload.dig("data", "attributes", "files").map { |file| file["filename"] }
        expect(filenames).to include("sample.txt")
      end
    end

    context "for a friends-only event" do
      let(:event) { create(:event, visibility: :friends, user: host, event_category: category) }

      it "allows accepted participants to upload files" do
        event.event_participations.create!(user: friend, rsvp_status: :accepted)

        friend_headers = { "Authorization" => "Bearer #{JwtService.encode(user_id: friend.id)}" }

        expect do
          post upload_files_api_v1_event_path(event),
               headers: friend_headers,
               params: { event: { files: [ fixture_file ] } }
        end.to change { event.reload.files.count }.by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "when the event is public" do
      let(:event) { create(:event, visibility: :public, user: host, event_category: category) }

      it "denies upload" do
        post upload_files_api_v1_event_path(event),
             headers: headers,
             params: { event: { files: [ fixture_file ] } }

        expect(response).to have_http_status(:forbidden)
        expect(event.reload.files).not_to be_attached
      end
    end

    context "when the user is not a participant" do
      let(:event) { create(:event, visibility: :private, user: host, event_category: category) }
      let(:stranger) { create(:user) }

      it "denies upload" do
        stranger_headers = { "Authorization" => "Bearer #{JwtService.encode(user_id: stranger.id)}" }

        post upload_files_api_v1_event_path(event),
             headers: stranger_headers,
             params: { event: { files: [ fixture_file ] } }

        expect(response).to have_http_status(:forbidden)
        expect(event.reload.files).not_to be_attached
      end
    end

    context "when no files are provided" do
      let(:event) { create(:event, visibility: :private, user: host, event_category: category) }

      it "returns unprocessable entity" do
        post upload_files_api_v1_event_path(event),
             headers: headers,
             params: { event: { files: [] } }

        expect(response.status).to eq(422)
        expect(JSON.parse(response.body)["error"]).to eq("No files provided")
      end
    end
  end
end
