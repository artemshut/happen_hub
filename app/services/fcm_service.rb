require "googleauth"
require "faraday"
require "json"

class FcmService
  FCM_SCOPE = "https://www.googleapis.com/auth/firebase.messaging"
  FCM_ENDPOINT = "https://fcm.googleapis.com/v1/projects"

  def initialize
    creds = Rails.application.credentials.dig(:fcm)
    @project_id = creds[:project_id]

    @authorizer = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new({
        "type" => "service_account",
        "client_email" => creds[:client_email],
        "private_key" => creds[:private_key]
      }.to_json),
      scope: FCM_SCOPE
    )
  end

  def send_notification(token, title:, body:, data: {})
    @authorizer.fetch_access_token!
    conn = Faraday.new(url: "#{FCM_ENDPOINT}/#{@project_id}/messages:send")

    message = {
      message: {
        token: token,
        notification: {
          title: title,
          body: body
        },
        data: data
      }
    }

    response = conn.post do |req|
      req.headers["Authorization"] = "Bearer #{@authorizer.access_token}"
      req.headers["Content-Type"] = "application/json"
      req.body = message.to_json
    end

    Rails.logger.info("📩 FCM Response: #{response.status} #{response.body}")
    response
  end
end
