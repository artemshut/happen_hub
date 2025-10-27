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
    sign_in host
    create(:friendship, user: host, friend: friend, status: :accepted)
    allow(UserMailer).to receive(:send_event_participation_notification).and_return(double(deliver_now: true))
  end

  it "renders updated availability when start time changes" do
    conflicting_event = create(
      :event,
      user: host,
      event_category: category,
      start_time: Time.zone.parse("2025-02-10 19:00"),
      end_time: Time.zone.parse("2025-02-10 21:00")
    )
    create(:event_participation, event: conflicting_event, user: friend, rsvp_status: :accepted)

    get availability_preview_event_path(event),
        params: { start_time: "2025-02-10T18:00", end_time: "2025-02-10T20:00" },
        headers: { "ACCEPT" => "text/vnd.turbo-stream.html" }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Busy")
  end
end
