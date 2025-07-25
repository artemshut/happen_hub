# app/mailers/concerns/enveloop_delivery.rb
module EnveloopDelivery
  include Rails.application.routes.url_helpers 

  
  private

  def enveloop
    @enveloop ||= Enveloop::Client.new(api_key: Rails.application.credentials.dig(:enveloop, :live_api_key))
  end

  def send_enveloop_message(template:, to:, subject:, from:, template_variables:)
    enveloop.send_message(
      template: template,
      to: to,
      from: from,
      subject: subject,
      template_variables: template_variables
    )
  end
end
