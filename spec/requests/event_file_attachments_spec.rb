# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Event file attachments", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:user) { create(:user) }
  let(:category) { create(:event_category) }
  let(:start_time) { Time.zone.parse("2025-03-10 18:00") }
  let(:end_time) { Time.zone.parse("2025-03-10 20:00") }
  let(:fixture_path) { Rails.root.join("spec/fixtures/files/sample.txt") }
  let!(:event) do
    create(
      :event,
      user: user,
      event_category: category,
      start_time: start_time,
      end_time: end_time
    ).tap do |record|
      File.open(fixture_path, "rb") do |file|
        record.files.attach(
          io: file,
          filename: "sample.txt",
          content_type: "text/plain"
        )
      end
    end
  end

  before { sign_in user, scope: :user }

  describe "GET /events/:id/edit" do
    it "renders existing attachments" do
      get edit_event_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("sample.txt")
    end
  end

  describe "PATCH /events/:id" do
    it "keeps existing attachments when no new files are provided" do
      patch event_path(event),
            params: {
              event: {
                title: "Updated title",
                files: [""]
              }
            }

      updated_event = event.reload
      expect(response).to redirect_to(event_path(updated_event))
      expect(updated_event.files).to be_attached
      expect(updated_event.files.map { |file| file.filename.to_s }).to include("sample.txt")
    end

    it "adds new files without removing existing ones" do
      new_file = fixture_file_upload("sample.txt", "text/plain")

      patch event_path(event),
            params: {
              event: {
                title: "Updated title again",
                files: [new_file]
              }
            }

      updated_event = event.reload
      expect(response).to redirect_to(event_path(updated_event))
      expect(updated_event.files.count).to eq(2)
    end
  end
end
