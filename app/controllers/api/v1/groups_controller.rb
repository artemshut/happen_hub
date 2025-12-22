class Api::V1::GroupsController < Api::V1::BaseController
  before_action :set_group, only: [ :show, :update, :destroy ]

  def index
    groups = policy_scope(Group).includes(:members)
    updated_after = parse_iso8601_param(:updated_after)
    return if performed?
    groups = groups.where(Group.arel_table[:updated_at].gt(updated_after)) if updated_after.present?
    groups = groups.page(page_param).per(per_page_param)
    last_modified = groups.maximum(:updated_at)
    return if halt_if_fresh!(
      etag_components: [ "groups#index", last_modified&.utc&.to_i, groups.total_count, params[:updated_after], groups.current_page, groups.limit_value ],
      last_modified: last_modified
    )

    render json: GroupSerializer.new(groups, include: [ :members ], meta: pagination_meta(groups)).serializable_hash
  end

  def show
    authorize @group
    return if halt_if_fresh!(
      etag_components: [ "groups#show", @group.cache_key_with_version ],
      last_modified: @group.updated_at
    )

    render json: GroupSerializer.new(@group, include: [ :members ]).serializable_hash
  end

  def create
    group = current_api_user.created_groups.build(group_params(true))
    authorize group

    if group.save
      render json: GroupSerializer.new(group, include: [ :members ]).serializable_hash, status: :created
    else
      render json: { errors: group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    authorize @group

    if @group.update(group_params)
      render json: GroupSerializer.new(@group, include: [ :members ]).serializable_hash, status: :ok
    else
      render json: { errors: @group.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @group

    @group.destroy
    head :no_content
  end

  private

  def set_group
    @group = Group.includes(:members).find(params[:id])
  end

  def group_params(force_membership = false)
    permitted = params.require(:group).permit(:name, :description, member_ids: [])
    member_ids = permitted.fetch(:member_ids, nil)

    if member_ids.present? || force_membership
      ids = Array(member_ids).reject(&:blank?).map(&:to_i)
      ids << current_api_user.id
      permitted[:member_ids] = ids.uniq
    else
      permitted.delete(:member_ids)
    end

    permitted
  end
end
