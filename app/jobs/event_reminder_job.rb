class EventReminderJob < ApplicationJob
  queue_as :default

  # minutes_before: integer – e.g., 1440 (24h), 60 (1h)
  def perform(user_id, minutes_before)
    # event = Event.find_by(id: event_id)
    # return unless event&.start_time.present?

    # # Don’t send if we’re already past the event
    # return if Time.current >= event.start_time

    # # Target users: accepted or maybe
    # user_ids = event.event_participations
    #                 .where(rsvp_status: %w[accepted maybe])
    #                 .pluck(:user_id)
    # users = User.where(id: user_ids).where.not(fcm_token: [ nil, "" ])
    # return if users.empty?

    # # Friendly copy per offset
    # title, body =
    #   case minutes_before
    #   when 1440
    #     [ "⏰ Reminder: #{event.title} starts tomorrow!",
    #      "Don't forget — it starts in 24 hours." ]
    #   when 60
    #     [ "⏳ Almost time: #{event.title}",
    #      "Starts in about 1 hour. See you soon!" ]
    #   else
    #     [ "Reminder: #{event.title}",
    #      "Starts soon." ]
    #   end

    # data = { "event_id" => event.id.to_s }

    # fcm = FcmService.new
    # users.each do |u|
    #   fcm.send_notification(u.fcm_token, title:, body:, data:)
    # end

    # Rails.logger.info "📬 Sent #{minutes_before} min reminder for event ##{event.id} to #{users.count} users"
    user = User.find_by(id: user_id)
    return unless user&.fcm_token.present?

    title = "Test Notification"
    body = "This is a test notification from EventReminderJob."

    data = { "test" => "true" }

    fcm = FcmService.new
    fcm.send_notification(user.fcm_token, title:, body:, data:)

    Rails.logger.info "📬 Sent test notification to user ##{user.id}"
  end
end
