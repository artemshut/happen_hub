# frozen_string_literal: true

module MailgunDelivery
  extend ActiveSupport::Concern

  private

  def send_mailgun_message(template:, assigns: {}, to:, subject:, from: nil)
    html = render_mailgun_template(template, assigns)
    text = ActionView::Base.full_sanitizer.sanitize(html)

    MailgunService.send_email(
      to: to,
      subject: subject,
      text: text,
      html: html,
      from: from
    )
  end

  def render_mailgun_template(template, assigns)
    assigns.each { |key, value| instance_variable_set("@#{key}", value) }
    render_to_string(template)
  ensure
    assigns.each_key do |key|
      next unless instance_variable_defined?("@#{key}")

      remove_instance_variable("@#{key}")
    end
  end
end
