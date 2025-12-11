# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventParticipation, type: :model do
  describe "callbacks" do
    describe "#notify_invitee" do
      let(:event) { create(:event) }
      let(:user) { create(:user) }
      let(:mailer_double) { double(deliver_now: true) }

      it "sends a notification for accepted participations" do
        expect(UserMailer)
          .to receive(:send_event_participation_notification)
          .with(user, event)
          .and_return(mailer_double)

        create(:event_participation, event: event, user: user, rsvp_status: :accepted)
      end

      it "sends a notification for maybe participations" do
        expect(UserMailer)
          .to receive(:send_event_participation_notification)
          .with(user, event)
          .and_return(mailer_double)

        create(:event_participation, event: event, user: user, rsvp_status: :maybe)
      end

      it "does not send notifications for declined participations" do
        expect(UserMailer).not_to receive(:send_event_participation_notification)

        create(:event_participation, event: event, user: user, rsvp_status: :declined)
      end

      it "does not send notifications for pending participations" do
        expect(UserMailer).not_to receive(:send_event_participation_notification)

        create(:event_participation, event: event, user: user, rsvp_status: :pending)
      end
    end
  end
end
