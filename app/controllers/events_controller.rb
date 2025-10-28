class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy add_friend update_rsvp invite_group remove_file availability_preview]
  before_action :authorize_event, only: %i[show edit update destroy add_friend invite_group remove_file availability_preview]
  before_action :authorize_event_rsvp, only: %i[update_rsvp]

  def index
    authorize Event

    @events = if params[:past] == "true"
                Event.visible_to(current_user).past.order(start_time: :desc)
    else
                Event.visible_to(current_user).upcoming.ordered_by_start
    end

    @events = @events.includes(:event_category)
    @events = @events.where(event_category_id: params[:category_id]) if params[:category_id].present?
    @events = @events.page(params[:page])

    @event_categories = EventCategory.joins(:events).where(events: { id: @events.pluck(:id) }).distinct

    respond_to do |format|
      format.html
      format.turbo_stream { render partial: "events/events_list", locals: { events: @events } }
    end
  end

  def show
    @comment = Comment.new
    @participants_by_status = @event.participants_grouped_for(current_user)
    @participant_count = @event.participant_count
    load_friend_invite_context(@event)
  end

  def new
    @event = Event.new
    authorize @event

    @event_categories = EventCategory.all
    @event.start_time = params[:date] if params[:date].present?
  end

  def add_friend
    friend = User.find(params[:friend_id])
    if @event.add_friend_with_rsvp(friend, params[:rsvp_status])
      redirect_to event_path(@event), notice: "Friend added to the event with RSVP."
    else
      redirect_to event_path(@event), alert: "Unable to add friend to the event."
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
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "invitation_status",
            partial: "events/invitation_status_full",
            locals: {
              event: @event,
              participants_by_status: @event.participants_grouped_for(current_user),
              participant_count: @event.participant_count
            }
          )
        end
        format.html { redirect_to event_path(@event), alert: "Failed to update RSVP status." }
      end
    end
  end

  def create
    @event = current_user.owned_events.new(event_params)
    authorize @event

    if @event.save!
      @event.event_participations.create(user: current_user, rsvp_status: "maybe")
      Activity.create(
        user: current_user,
        action: "created_event",
        target: @event,
        metadata: { event_name: @event.title }
      )
      redirect_to event_path(@event), notice: "Event created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /groups/:group_id/events/:id/edit
  def edit
    @event_categories = EventCategory.all
    load_friend_invite_context(@event)
  end

  # PATCH/PUT /groups/:group_id/events/:id
  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: "Event updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /groups/:group_id/events/:id
  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted successfully."
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

  def remove_file
    file = @event.files.find(params[:file_id])
    file.purge
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("files_panel", partial: "events/files_panel", locals: { event: @event })
      end
      format.html { redirect_to @event, notice: "File removed." }
    end
  end

  def availability_preview
    preview_event = @event.dup
    preview_event.id = @event.id
    preview_event.start_time = parse_datetime(params[:start_time]) || @event.start_time
    preview_event.end_time = parse_datetime(params[:end_time]) || @event.end_time

    load_friend_invite_context(preview_event)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "friend_invite_list",
          partial: "events/friend_invite_list",
          locals: {
            event: @event,
            friends: @friends,
            friend_availabilities: @friend_availabilities
          }
        )
      end
      format.html { redirect_to event_path(@event) }
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:id])
  end

  def authorize_event
    authorize @event
  end

  def authorize_event_rsvp
    authorize @event, :update_rsvp?
  end

  def event_params
    params.require(:event).permit(
      :title, :description, :rsvp_status, :start_time, :end_time,
      :location, :latitude, :longitude, :visibility, :cover_image,
      :event_category_id, files: [],
    )
  end

  def load_friend_invite_context(event_for_availability)
    @friends = current_user.friends - @event.users
    @friend_availabilities = @friends.each_with_object({}) do |friend, hash|
      hash[friend.id] = InviteeAvailabilityService.call(event: event_for_availability, invitee: friend)
    end
  end

  def parse_datetime(value)
    return if value.blank?

    Time.zone.parse(value)
  rescue ArgumentError
    nil
  end
end
