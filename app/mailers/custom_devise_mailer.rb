class CustomDeviseMailer < Devise::Mailer
  include EnveloopDelivery

  default from: 'no-reply@happenhub.co'

  def reset_password_instructions(record, token, opts = {})
    reset_link = edit_password_url(record, reset_password_token: token)
    
    send_enveloop_message(
      template: "forgot-password",
      to: record.email,
      from: "no-reply@happenhub.co",
      subject: "Reset your password",
      template_variables: {
        reset_link: reset_link,
        user_email: record.email
      }
    )
  end
end
