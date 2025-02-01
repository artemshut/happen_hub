class UserMailer < ApplicationMailer
  default from: "no-reply@yourdomain.com"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: "Welcome to HappenHub!")
  end

  def friend_request_email(user, friend)
    @user = user
    @friend = friend
    mail(to: @friend.email, subject: "#{@user.full_name} sent you a friend request!")
  end

  def event_invitation_email(user, event)
    @user = user
    @event = event
    mail(to: @user.email, subject: "You’re invited to #{@event.title}!")
  end
end
