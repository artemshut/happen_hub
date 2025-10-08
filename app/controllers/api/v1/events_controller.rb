class Api::V1::EventsController < Api::V1::BaseController
  before_action :set_event, only: [:show, :update, :update_rsvp]

  # GET /api/v1/events
  def index
    authorize Event

    events = if params[:past] == "true"
               Event.past(current_api_user).includes(:event_category, :user)
             else
               Event.for_user(current_api_user).includes(:event_category, :user)
             end

    events = events.where(event_category_id: params[:category_id]) if params[:category_id].present?
    events = events.order(start_time: :asc)

    render json: EventSerializer.new(
      events,
      include: [:user, :users, :event_category, :event_participations, :comments, :"comments.user"]
    ).serializable_hash
  end

  # GET /api/v1/events/:id
  def show
    authorize @event

    render json: EventSerializer.new(
      @event,
      include: [:user, :users, :event_category, :comments, :likes, :event_participations, :"comments.user"]
    ).serializable_hash
  end

  # POST /api/v1/events
  def create
    @event = current_api_user.owned_events.new(event_params)
    authorize @event

    if @event.save
      @event.event_participations.create(user: current_api_user, rsvp_status: "maybe")
      Activity.create(
        user: current_api_user,
        action: "created_event",
        target: @event,
        metadata: { event_name: @event.title }
      )

      render json: EventSerializer.new(
        @event,
        include: [:user, :event_category, :users, :comments, :likes, :event_participations, :"comments.user"]
      ).serializable_hash, status: :created
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/events/:id
  def update
    authorize @event

    if @event.update(event_params.except(:files))
      if params[:event][:files].present?
        params[:event][:files].each do |file|
          @event.files.attach(file)
        end
      end

      remove_files

      render json: EventSerializer.new(
        @event,
        include: [:user, :event_category, :users, :comments, :likes, :event_participations, :"comments.user"]
      ).serializable_hash, status: :ok
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # POST /api/v1/events/:id/rsvp
  def update_rsvp
    authorize @event, :update_rsvp?

    status = params[:status].to_s.downcase
    unless EventParticipation.rsvp_statuses.key?(status)
      return render json: { error: "Invalid RSVP status" }, status: :unprocessable_entity
    end

    participation = @event.event_participations.find_or_initialize_by(user: current_api_user)

    if participation.update(rsvp_status: status)
      render json: {
        event: EventSerializer.new(
          @event,
          include: [:user, :event_category, :users, :event_participations]
        ).serializable_hash,
        rsvp_status: participation.rsvp_status
      }, status: :ok
    else
      render json: { errors: participation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.friendly.find(params[:id])
  end

  def event_params
    params.require(:event).permit(
      :title,
      :description,
      :start_time,
      :end_time,
      :location,
      :latitude,
      :longitude,
      :event_category_id,
      :visibility,
      :cover_image,
      files: []
    )
  end

  def remove_files
    return unless params[:event][:removed_files].present?

    params[:event][:removed_files].each do |signed_id|
      blob = ActiveStorage::Blob.find_signed(signed_id)
      next unless blob

      attachment = @event.files.find_by(blob_id: blob.id)
      attachment&.purge
    end
  end
end
