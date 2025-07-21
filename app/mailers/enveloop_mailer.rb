class EnveloopMailer < ActionMailer::Base

  include Rails.application.routes.url_helpers 

  def user_welcome_email(recipient)
     enveloop.send_message(
        template: 'user-welcome',
        to: recipient.email,
        from: 'hello@happenhub.com',
        subject: 'Welcome to HappenHub',
        template_variables:{
           account_url: 'https://myapp.com',
           username: recipient.full_name,
           user_tag: recipient.tag,
        }
     )
  end

  private

  def enveloop
     @enveloop ||= Enveloop::Client.new(api_key: Rails.application.credentials.dig(:enveloop, :live_api_key)) 
  end

end