# frozen_string_literal: true

require "rails_helper"

RSpec.describe InviteeAvailabilityService do
  let(:host) { create(:user) }
  let(:invitee) { create(:user) }
  let(:category) { create(:event_category) }

  let(:target_event) do
    create(
      :event,
      event_category: category,
      user: host,
      start_time: Time.zone.parse("2025-02-10 18:00"),
      end_time: Time.zone.parse("2025-02-10 20:00")
    )
  end

  describe ".call" do
    subject(:service_call) { described_class.call(event: target_event, invitee:) }

    let(:conflicting_start_time) { Time.zone.parse("2025-02-10 19:00") }
    let(:conflicting_end_time)   { Time.zone.parse("2025-02-10 21:00") }

    context "when the invitee has no overlapping participations" do
      let!(:non_conflicting_event) do
        create(
          :event,
          event_category: category,
          user: host,
          start_time: Time.zone.parse("2025-02-10 14:00"),
          end_time: Time.zone.parse("2025-02-10 16:00")
        )
      end

      before do
        create(:event_participation, event: non_conflicting_event, user: invitee, rsvp_status: :accepted)
      end

      it "returns free status and no conflicts" do
        expect(service_call[:status]).to eq("free")
        expect(service_call[:conflicts]).to be_empty
      end
    end

    context "when the invitee has an overlapping accepted participation" do
      let!(:conflicting_event) do
        create(
          :event,
          event_category: category,
          user: host,
          start_time: conflicting_start_time,
          end_time: conflicting_end_time
        )
      end

      before do
        create(:event_participation, event: conflicting_event, user: invitee, rsvp_status: :accepted)
      end

      it "returns busy status with the conflicting participation" do
        result = service_call
        expect(result[:status]).to eq("busy")
        expect(result[:conflicts].count).to eq(1)
        expect(result[:conflicts].first[:rsvp_status]).to eq("accepted")
      end
    end

    context "when the invitee only has overlapping tentative participations" do
      let!(:conflicting_event) do
        create(
          :event,
          event_category: category,
          user: host,
          start_time: conflicting_start_time,
          end_time: conflicting_end_time
        )
      end

      before do
        create(:event_participation, event: conflicting_event, user: invitee, rsvp_status: :maybe)
      end

      it "returns tentative status" do
        expect(service_call[:status]).to eq("tentative")
      end
    end

    context "when the invitee has overlapping pending participations" do
      let!(:conflicting_event) do
        create(
          :event,
          event_category: category,
          user: host,
          start_time: conflicting_start_time,
          end_time: conflicting_end_time
        )
      end

      before do
        create(:event_participation, event: conflicting_event, user: invitee, rsvp_status: :pending)
      end

      it "treats pending as tentative" do
        expect(service_call[:status]).to eq("tentative")
      end
    end

    context "when the target event is missing times" do
      before do
        target_event.update_columns(end_time: nil)
      end

      it "returns unknown status" do
        expect(service_call[:status]).to eq("unknown")
      end
    end

    context "when invitee has participations with incomplete times" do
      let!(:incomplete_event) do
        create(:event, event_category: category, user: host).tap do |event|
          event.update_columns(start_time: nil, end_time: nil)
        end
      end

      before do
        allow(UserMailer)
          .to receive(:send_event_participation_notification)
          .and_return(double(deliver_now: true))

        create(:event_participation, event: incomplete_event, user: invitee, rsvp_status: :accepted)
      end

      it "returns unknown status with explanatory note" do
        result = service_call
        expect(result[:status]).to eq("unknown")
        expect(result[:conflicts]).to be_empty
        expect(result[:note]).to be_present
      end
    end
  end
end
