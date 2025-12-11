# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer do
  describe "#welcome_email" do
    let(:user) { create(:user) }

    it "sends via MailgunService" do
      expect(MailgunService).to receive(:send_email).with(
        to: user.email,
        subject: "Welcome to HappenHub",
        text: kind_of(String),
        html: kind_of(String),
        from: "no-reply@happenhub.co"
      ).and_return(true)

      described_class.welcome_email(user).deliver_now
    end
  end

  describe "#send_confirmation_instructions" do
    let(:user) { create(:user, confirmation_token: "token-123") }

    it "sends confirmation details via MailgunService" do
      expect(MailgunService).to receive(:send_email).with(
        to: user.email,
        subject: "Confirm your HappenHub account",
        text: kind_of(String),
        html: kind_of(String),
        from: "no-reply@happenhub.co"
      ).and_return(true)

      described_class.send_confirmation_instructions(user).deliver_now
    end
  end

  describe "#send_event_participation_notification" do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it "notifies the participant via MailgunService" do
      expect(MailgunService).to receive(:send_email).with(
        to: user.email,
        subject: "You are invited to an event",
        text: kind_of(String),
        html: kind_of(String),
        from: "no-reply@happenhub.co"
      ).and_return(true)

      described_class.send_event_participation_notification(user, event).deliver_now
    end
  end

  describe "#send_friend_request_notification" do
    let(:friend) { create(:user) }
    let(:requestor) { create(:user) }

    it "emails the friend via MailgunService" do
      expect(MailgunService).to receive(:send_email).with(
        to: friend.email,
        subject: "Friend Request from #{requestor.full_name}",
        text: kind_of(String),
        html: kind_of(String),
        from: "no-reply@happenhub.co"
      ).and_return(true)

      described_class.send_friend_request_notification(friend, requestor).deliver_now
    end
  end
end
