class CustomDeviseMailer < Devise::Mailer
  include MailgunDelivery

  default from: "no-reply@happenhub.co"
  layout "mailer"

  def reset_password_instructions(record, token, opts = {})
    reset_link = edit_user_password_url(reset_password_token: token, host: "happenhub.co")

    send_mailgun_message(
      template: "devise/mailer/reset_password_instructions",
      assigns: {
        resource: record,
        token: token,
        reset_link: reset_link
      },
      to: record.email,
      subject: "Reset your password",
      from: "no-reply@happenhub.co"
    )
  end
end
