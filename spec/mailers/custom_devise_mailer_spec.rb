# frozen_string_literal: true

require "rails_helper"

RSpec.describe CustomDeviseMailer do
  describe "#reset_password_instructions" do
    let(:user) { create(:user) }
    let(:token) { "reset-token" }

    it "delegates delivery to MailgunService" do
      expect(MailgunService).to receive(:send_email).with(
        to: user.email,
        subject: "Reset your password",
        text: kind_of(String),
        html: kind_of(String),
        from: "no-reply@happenhub.co"
      ).and_return(true)

      described_class.reset_password_instructions(user, token).deliver_now
    end
  end
end
