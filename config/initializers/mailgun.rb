require "mailgun-ruby"

mailgun_api_key = Rails.application.credentials.dig(:mailgun, :sending_key)
MailgunClient = if mailgun_api_key.present?
  Mailgun::Client.new(mailgun_api_key)
else
  nil
end
