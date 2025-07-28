class UserMailer < ApplicationMailer
  include EnveloopDelivery

  def welcome_email(user)
    send_enveloop_message(
      template: 'user-welcome',
      to: user.email,
      from: 'no-reply@happenhub.co',
      subject: 'Welcome to HappenHub',
      template_variables: {
        account_url: 'https://myapp.com',
        username: user.full_name,
        user_tag: user.tag
      }
    )
  end

  def send_confirmation_instructions(user)
    send_enveloop_message(
      template: 'confirm-account',
      to: user.email,
      from: 'no-reply@happenhub.co',
      subject: 'Confirm your HappenHub account',
      template_variables: {
        host: 'happenhub.co',
        confirmation_url: Rails.application.routes.url_helpers.user_confirmation_url(confirmation_token: user.confirmation_token, host: "happenhub.co")
      }
    )
  end
end
