class LikesController < ApplicationController
  def create
    @likeable = find_likeable
    current_user.likes.create(likeable: @likeable)
    respond_to(&:turbo_stream)
  end

  def destroy
    @likeable = find_likeable
    like = current_user.likes.find_by(likeable: @likeable)
    like&.destroy
    respond_to(&:turbo_stream)
  end

  private

  def find_likeable
    likeable_class = Like::ALLOWED_LIKEABLE_TYPES[params[:likeable_type]]
    return head :bad_request unless likeable_class

    likeable_class.find(params[:likeable_id])
  end
end
