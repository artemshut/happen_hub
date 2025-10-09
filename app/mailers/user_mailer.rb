class UserMailer < ApplicationMailer
  include EnveloopDelivery

  def welcome_email(user)
    send_enveloop_message(
      template: "user-welcome",
      to: user.email,
      from: "no-reply@happenhub.co",
      subject: "Welcome to HappenHub",
      template_variables: {
        account_url: "https://happenhub.co/profile",
        username: user.full_name,
        user_tag: user.tag
      }
    )
  end

  def send_confirmation_instructions(user)
    send_enveloop_message(
      template: "confirm-account",
      to: user.email,
      from: "no-reply@happenhub.co",
      subject: "Confirm your HappenHub account",
      template_variables: {
        confirmation_url: Rails.application.routes.url_helpers.user_confirmation_url(confirmation_token: user.confirmation_token, host: "happenhub.co")
      }
    )
  end

  def send_event_participation_notification(user, event)
    send_enveloop_message(
      template: "participation-notification",
      to: user.email,
      from: "no-reply@happenhub.co",
      subject: "You are invited to an event",
      template_variables: {
        event_url: Rails.application.routes.url_helpers.event_url(event, host: "happenhub.co"),
        event_name: event.title,
        event_date: event.start_time.strftime("%B %d, %Y at %I:%M %p"),
        user_name: user.full_name
      }
    )
  end

  def send_friend_request_notification(friend, user)
    send_enveloop_message(
      template: "friend-request",
      to: friend.email,
      from: "no-reply@happenhub.co",
      subject: "Friend Request from #{user.full_name}",
      template_variables: {
        friendships_url: Rails.application.routes.url_helpers.friendships_url(host: "happenhub.co"),
        friend_name: friend.full_name,
        user_name: user.full_name
      }
    )
  end
end
