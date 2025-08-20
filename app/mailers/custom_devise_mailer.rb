class CustomDeviseMailer < Devise::Mailer
  include EnveloopDelivery

  default from: 'no-reply@happenhub.co'

  def reset_password_instructions(record, token, opts = {})
    reset_link = edit_user_password_url(reset_password_token: token, host: "happenhub.co")
    
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
