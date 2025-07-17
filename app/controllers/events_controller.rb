class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy add_friend update_rsvp invite_group]
  before_action :authorize_user!, only: %i[edit update destroy add_friend update_rsvp invite_group]

  # GET /groups/:group_id/events
  def index
    # Events the user owns or participates in
    own_or_participating = Event.left_joins(:event_participations)
                                .where("event_participations.user_id = ? OR events.user_id = ?", current_user.id, current_user.id)

    # Events visible to the user's friends
    friends_visible = Event.visible_for_friend(current_user)

    @events = (own_or_participating + friends_visible).uniq
  end

  # GET /groups/:group_id/events/:id
  def show
    @comment = Comment.new
    @friends = current_user.friends - @event.users
  end

  # GET /groups/:group_id/events/new
  def new
    @event = Event.new
    @event.start_time = params[:date] if params[:date].present?
  end

  def add_friend
    friend = User.find(params[:friend_id])
    if @event.add_friend_with_rsvp(friend, params[:rsvp_status])
      redirect_to event_path(@event), notice: 'Friend added to the event with RSVP.'
    else
      redirect_to event_path(@event), alert: 'Unable to add friend to the event.'
    end
  end

  def update_rsvp
    participation = @event.event_participations.find_by(user_id: current_user.id) || @event.event_participations.create(user_id: current_user.id)

    if participation&.update(rsvp_status: params[:status])
      respond_to do |format|
        format.turbo_stream # Render a Turbo Stream template
        format.html { redirect_to event_path(@event), notice: "Your RSVP status has been updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("invitation_status", partial: "events/invitation_status_full", locals: { error: "Failed to update status." }) }
        format.html { redirect_to event_path(@event), alert: "Failed to update RSVP status." }
      end
    end
  end

  def create
    @event = Event.new(event_params)
    @event.user = current_user
    if @event.save!
      Activity.create(
        user: current_user,
        action: "created_event",
        target: @event,
        metadata: { event_name: @event.title }
      )
      redirect_to event_path(@event), notice: 'Event created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:group_id/events/:id/edit
  def edit
  end

  # PATCH/PUT /groups/:group_id/events/:id
  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: 'Event updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:group_id/events/:id
  def destroy
    @event.destroy
    redirect_to events_path, notice: 'Event deleted successfully.'
  end

  def invite_group
    @group = Group.find(params[:group_id])

    # Invite all group members to the event
    @group.members.each do |member|
      unless @event.event_participations.exists?(user: member)
        @event.event_participations.create(user: member, rsvp_status: :pending)
      end
    end

    redirect_to event_path(@event), notice: "Invitations sent to all members of #{@group.name}."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_user!
    unless @event.user == current_user || @event.users.include?(current_user) || Event.visible_for_friend(current_user).include?(@event)
      redirect_to events_path, alert: 'Not authorized.' 
    end
  end

  def event_params
    params.require(:event).permit(:title, :description, :rsvp_status, :start_time, :end_time, :location, :latitude, :longitude, :visibility)
  end
end
