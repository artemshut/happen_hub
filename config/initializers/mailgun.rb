require "mailgun-ruby"

mailgun_credentials = Rails.application.credentials[:mailgun] || {}
mailgun_api_key = mailgun_credentials[:sending_key]
mailgun_host = mailgun_credentials[:api_host]

MailgunClient = if mailgun_api_key.present?
  Mailgun::Client.new(mailgun_api_key, mailgun_host)
else
  nil
end
