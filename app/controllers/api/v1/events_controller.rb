class Api::V1::EventsController < Api::V1::BaseController
  before_action :set_event, only: [:show, :update, :destroy]

  # GET /api/v1/events
  def index
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
    render json: EventSerializer.new(
      @event,
      include: [:user, :users, :event_category, :comments, :likes, :event_participations, :"comments.user"]
    ).serializable_hash
  end

  # POST /api/v1/events
  def create
    @event = current_api_user.owned_events.new(event_params)

    if @event.save
      @event.event_participations.create(user: current_api_user, rsvp_status: "maybe")
      Activity.create(
        user: current_api_user,
        action: "created_event",
        target: @event,
        metadata: { event_name: @event.title }
      )
      attach_files
      attach_cover_image
      render json: EventSerializer.new(
        @event,
        include: [:user, :event_category, :users, :comments, :likes, :event_participations, :"comments.user"]
      ).serializable_hash, status: :created
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT/PATCH /api/v1/events/:id
  def update
    if @event.user_id != current_api_user.id
      return render json: { error: "Not authorized" }, status: :forbidden
    end

    if @event.update(event_params)
      attach_files
      attach_cover_image
      remove_files

      render json: EventSerializer.new(
        @event,
        include: [:user, :event_category, :users, :comments, :likes, :event_participations, :"comments.user"]
      ).serializable_hash, status: :ok
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
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
      files: [],
      removed_files: []
    )
  end

  def attach_files
    return unless params[:files].present?

    params[:files].each do |file|
      @event.files.attach(file)
    end
  end

  def attach_cover_image
    return unless params[:cover_image].present?

    @event.cover_image.purge if @event.cover_image.attached? # replace old
    @event.cover_image.attach(params[:cover_image])
  end

  def remove_files
    return unless params[:removed_files].present?

    params[:removed_files].each do |file_id|
      blob = ActiveStorage::Blob.find_signed(file_id) rescue nil
      next unless blob

      attachment = @event.files.find_by(blob_id: blob.id)
      attachment&.purge
    end
  end
end