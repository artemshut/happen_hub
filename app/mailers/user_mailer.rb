class UserMailer < ApplicationMailer
  include MailgunDelivery

  def welcome_email(user)
    send_mailgun_message(
      template: "user_mailer/welcome_email",
      assigns: {
        user: user,
        username: user.full_name,
        user_tag: user.tag,
        account_url: "https://happenhub.co/profile"
      },
      to: user.email,
      subject: "Welcome to HappenHub",
      from: "no-reply@happenhub.co"
    )
  end

  def send_confirmation_instructions(user)
    confirmation_url = Rails.application.routes.url_helpers.user_confirmation_url(
      confirmation_token: user.confirmation_token,
      host: "happenhub.co"
    )

    send_mailgun_message(
      template: "user_mailer/send_confirmation_instructions",
      assigns: {
        user: user,
        confirmation_url: confirmation_url
      },
      to: user.email,
      subject: "Confirm your HappenHub account",
      from: "no-reply@happenhub.co"
    )
  end

  def send_event_participation_notification(user, event)
    send_mailgun_message(
      template: "user_mailer/send_event_participation_notification",
      assigns: {
        user: user,
        event_name: event.title,
        event_date: event.start_time.strftime("%B %d, %Y at %I:%M %p"),
        event_url: Rails.application.routes.url_helpers.event_url(event, host: "happenhub.co")
      },
      to: user.email,
      subject: "You are invited to an event",
      from: "no-reply@happenhub.co"
    )
  end

  def send_friend_request_notification(friend, user)
    send_mailgun_message(
      template: "user_mailer/send_friend_request_notification",
      assigns: {
        friend_name: friend.full_name,
        user_name: user.full_name,
        friendships_url: Rails.application.routes.url_helpers.friendships_url(host: "happenhub.co")
      },
      to: friend.email,
      subject: "Friend Request from #{user.full_name}",
      from: "no-reply@happenhub.co"
    )
  end
end
