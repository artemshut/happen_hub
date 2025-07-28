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
end
