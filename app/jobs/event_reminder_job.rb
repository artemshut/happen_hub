class EventReminderJob < ApplicationJob
  queue_as :default

  def perform(event_id)
    event = Event.find_by(id: event_id)
    return unless event
    return if event.start_time.blank? || Time.current >= event.start_time

    # Find users with accepted or maybe RSVP
    user_ids = event.event_participations
                    .where(rsvp_status: %w[accepted maybe])
                    .pluck(:user_id)
    users = User.where(id: user_ids).where.not(fcm_token: [nil, ""])

    return if users.empty?

    fcm = FcmService.new
    title = "⏰ Reminder: #{event.title} starts tomorrow!"
    body  = "Don't forget — your event starts in 24 hours."
    data  = { "event_id" => event.id.to_s }

    users.each do |user|
      fcm.send_notification(user.fcm_token, title:, body:, data:)
    end

    Rails.logger.info("📬 Sent 24h reminder for event ##{event.id} to #{users.count} users")
  end
end