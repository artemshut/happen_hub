# frozen_string_literal: true

RSpec.configure do |config|
  config.before do
    allow(MailgunService).to receive(:send_email).and_return(true)
  end
end
