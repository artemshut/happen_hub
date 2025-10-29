class MailgunService
  def self.send_email(to:, subject:, text:, html:)
    domain = Rails.application.credentials.dig(:mailgun, :domain)
    mg_client = MailgunClient

    message_params =  {
      from: "HappenHub <no-reply@#{domain}>",
      to: to,
      subject: subject,
      text: text,
      html: html
    }

    mg_client.send_message(domain, message_params)
  end
end
