class Api::V1::EventsController < Api::V1::BaseController
  before_action :set_event, only: [ :show, :update, :update_rsvp, :upload_files ]
  before_action :ensure_plan_capacity!, only: [ :create ]

  def index
    authorize Event

    events = Event.visible_to(current_api_user)
    events = params[:past] == "true" ? events.past.order(start_time: :desc) : events.upcoming.ordered_by_start

    events = events.includes(:event_category, :user, { comments: :user }, { likes: :user })
    events = events.where(event_category_id: params[:category_id]) if params[:category_id].present?
    updated_after = parse_iso8601_param(:updated_after)
    return if performed?
    events = events.where(Event.arel_table[:updated_at].gt(updated_after)) if updated_after.present?
    events = events.page(page_param).per(per_page_param)
    last_modified = events.maximum(:updated_at)
    return if halt_if_fresh!(
      etag_components: [ "events#index", last_modified&.utc&.to_i, events.total_count, params[:category_id], params[:past], params[:updated_after], events.current_page, events.limit_value ],
      last_modified: last_modified
    )

    render json: EventSerializer.new(
      events,
      include: [ :user, :event_category, :comments, :likes, :"comments.user" ],
      params: serializer_params,
      meta: pagination_meta(events)
    ).serializable_hash
  end

  def show
    authorize @event
    return if halt_if_fresh!(
      etag_components: [ "events#show", @event.cache_key_with_version ],
      last_modified: @event.updated_at
    )

    render json: EventSerializer.new(
      @event,
      include: [ :user, :event_category, :comments, :likes, :"comments.user" ],
      params: serializer_params
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
        include: [ :user, :event_category, :comments, :likes, :"comments.user" ],
        params: serializer_params
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
        include: [ :user, :event_category, :comments, :likes, :"comments.user" ],
        params: serializer_params
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
      Missions::ProgressService.new(current_api_user).tick!(:attend_social, metadata: { event_id: @event.id }) if status == "accepted"
      render json: {
        event: EventSerializer.new(
          @event,
          include: [ :user, :event_category ],
          params: serializer_params
        ).serializable_hash,
        rsvp_status: participation.rsvp_status
      }, status: :ok
    else
      render json: { errors: participation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def upload_files
    authorize @event, :upload_files?

    new_files = Array(params.dig(:event, :files)).reject(&:blank?)
    return render json: { error: "No files provided" }, status: :unprocessable_entity if new_files.blank?

    @event.pending_files = new_files

    if @event.valid?
      attach_uploaded_files(@event, new_files)
      @event.reload
      render json: EventSerializer.new(
        @event,
        include: [ :user, :event_category, :comments, :likes, :event_participations ],
        params: serializer_params
      ).serializable_hash, status: :created
    else
      render json: { errors: @event.errors.full_messages }, status: :unprocessable_entity
    end
  ensure
    @event.pending_files = nil
  end

  private

  def set_event
    @event = Event.includes(:event_category, :user, { comments: :user }, { likes: :user }).friendly.find(params[:id])
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
      sub_events_attributes: [
        :id,
        :title,
        :start_time,
        :end_time,
        :location,
        :notes,
        :position,
        :_destroy
      ]
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

  def serializer_params
    { current_user: current_api_user, host: request.base_url }
  end

  def attach_uploaded_files(event, files)
    Array(files).each { |file| event.files.attach(file) }
  end

  def ensure_plan_capacity!
    return if current_api_user.can_create_event?

    render json: {
      error: "Plan limit reached",
      message: "Your #{current_api_user.plan.name} plan has reached its active event limit. Upgrade to create more events."
    }, status: :payment_required
  end
end
