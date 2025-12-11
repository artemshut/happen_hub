class MailgunService
  def self.send_email(to:, subject:, text:, html:, from: nil)
    domain = Rails.application.credentials.dig(:mailgun, :domain)
    mg_client = MailgunClient

    unless mailgun_configured?(mg_client, domain)
      Rails.logger.info("[MailgunService] Mailgun not configured. Skipping delivery to #{to}.")
      return
    end

    message_params = {
      from: from || default_from(domain),
      to: to,
      subject: subject,
      text: text,
      html: html
    }

    mg_client.send_message(domain, message_params)
  end

  def self.mailgun_configured?(client, domain)
    client.present? && domain.present?
  end
  private_class_method :mailgun_configured?

  def self.default_from(domain)
    "HappenHub <no-reply@#{domain}>"
  end
  private_class_method :default_from
end
