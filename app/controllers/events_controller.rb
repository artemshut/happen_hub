class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy add_friend update_rsvp]
  before_action :authorize_user!, only: %i[edit update destroy add_friend update_rsvp]

  # GET /groups/:group_id/events
  def index
    # Events the user owns or participates in
    own_or_participating = Event.left_joins(:event_participations)
                                .where("event_participations.user_id = ? OR events.user_id = ?", current_user.id, current_user.id)

    # Events visible to the user's friends
    friends_visible = Event.where(visibility: "friends")
                           .joins("INNER JOIN friendships ON friendships.friend_id = events.user_id")
                           .where("friendships.user_id = ?", current_user.id)

    # Combine the results using UNION
    @events = Event.from("(#{own_or_participating.to_sql} UNION #{friends_visible.to_sql}) AS events").distinct
  end

  # GET /groups/:group_id/events/:id
  def show
    @friends = current_user.friends - @event.users
  end

  # GET /groups/:group_id/events/new
  def new
    @event = current_user.events.new
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
        format.turbo_stream { render turbo_stream: turbo_stream.replace("invitation_status", partial: "events/invitation_status", locals: { error: "Failed to update status." }) }
        format.html { redirect_to event_path(@event), alert: "Failed to update RSVP status." }
      end
    end
  end

  def create
    @event = current_user.events.new(event_params)
    @event.user = current_user
    if @event.save!
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

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_user!
    redirect_to events_path, alert: 'Not authorized.' unless @event.user == current_user || @event.users.include?(current_user)
  end

  def event_params
    params.require(:event).permit(:title, :description, :rsvp_status, :start_time, :end_time, :location)
  end
end
