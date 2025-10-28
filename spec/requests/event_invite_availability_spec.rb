# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Event invite availability preview", type: :request do
  let(:host) { create(:user) }
  let(:friend) { create(:user) }
  let(:category) { create(:event_category) }
  let(:event) do
    create(
      :event,
      user: host,
      event_category: category,
      start_time: Time.zone.parse("2025-02-10 18:00"),
      end_time: Time.zone.parse("2025-02-10 20:00")
    )
  end

  before do
    sign_in host, scope: :user
    create(:friendship, user: host, friend: friend, status: :accepted)
    allow(UserMailer).to receive(:send_event_participation_notification).and_return(double(deliver_now: true))
  end

  describe "GET /events/:id/availability_preview" do
    subject(:render_preview) do
      get availability_preview_event_path(event),
          params: request_params,
          headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }
    end

    let(:request_params) do
      {
        start_time: event.start_time.iso8601,
        end_time: event.end_time.iso8601
      }
    end

    it "renders free when the invitee has no overlapping participations" do
      render_preview

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Free")
    end

    context "when the invitee has an overlapping accepted participation" do
      before do
        conflicting_event = create(
          :event,
          user: host,
          event_category: category,
          start_time: Time.zone.parse("2025-02-10 19:00"),
          end_time: Time.zone.parse("2025-02-10 21:00")
        )
        create(:event_participation, event: conflicting_event, user: friend, rsvp_status: :accepted)
      end

      it "shows the busy badge" do
        render_preview

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Busy")
      end
    end

    context "when the invitee has an overlapping tentative participation" do
      before do
        conflicting_event = create(
          :event,
          user: host,
          event_category: category,
          start_time: Time.zone.parse("2025-02-10 19:30"),
          end_time: Time.zone.parse("2025-02-10 21:30")
        )
        create(:event_participation, event: conflicting_event, user: friend, rsvp_status: :maybe)
      end

      it "shows the tentative badge" do
        render_preview

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Tentative")
      end
    end

    context "when the availability cannot be determined" do
      let(:request_params) { {} }

      before do
        event.update_columns(start_time: nil, end_time: nil)
      end

      it "shows the unknown badge" do
        render_preview

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Unknown")
      end
    end
  end
end
