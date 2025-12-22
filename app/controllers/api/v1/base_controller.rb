require "digest"
require "time"

class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization

  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE = 100

  before_action :authenticate_api_user!
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def authenticate_api_user!
    header = request.headers["Authorization"]
    token = header.split(" ").last if header.present?
    decoded = JwtService.decode(token)
    @current_api_user = User.find_by(id: decoded[:user_id]) if decoded

    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_api_user
    @current_api_user&.ensure_missions_assigned!
  end

  def current_api_user
    @current_api_user
  end

  def pundit_user
    current_api_user
  end

  def user_not_authorized
    render json: { error: "forbidden" }, status: :forbidden
  end

  def page_param
    page_number = params[:page].presence || 1
    page_number = page_number.to_i
    page_number.positive? ? page_number : 1
  end

  def per_page_param
    per_page = params[:per_page].presence || DEFAULT_PER_PAGE
    per_page = per_page.to_i
    per_page = DEFAULT_PER_PAGE if per_page <= 0
    [ per_page, MAX_PER_PAGE ].min
  end

  def pagination_meta(scope)
    return {} unless scope.respond_to?(:current_page)

    {
      current_page: scope.current_page,
      next_page: scope.next_page,
      prev_page: scope.prev_page,
      total_pages: scope.total_pages,
      total_count: scope.total_count
    }
  end

  def parse_iso8601_param(key)
    value = params[key]
    return if value.blank?

    Time.iso8601(value)
  rescue ArgumentError
    render json: { error: "#{key} must be ISO8601 formatted" }, status: :unprocessable_entity
    nil
  end

  def halt_if_fresh!(etag_components:, last_modified:)
    etag_value = apply_cache_headers!(etag_components:, last_modified:)
    return false unless conditional_request_fresh?(etag_value:, last_modified:)

    head :not_modified
    true
  end

  def apply_cache_headers!(etag_components:, last_modified:)
    compact_components = Array(etag_components).compact
    etag_value = Digest::MD5.hexdigest(compact_components.join(":")) if compact_components.any?
    response.set_header("ETag", %("#{etag_value}")) if etag_value
    response.set_header("Last-Modified", last_modified.httpdate) if last_modified
    etag_value
  end

  def conditional_request_fresh?(etag_value:, last_modified:)
    matches_etag = false

    if etag_value && (if_none_match = request.headers["If-None-Match"]).present?
      sanitized = if_none_match.delete_prefix("\"").delete_suffix("\"")
      matches_etag = sanitized == etag_value
    end

    validated_since = false
    if last_modified && (modified_since = request.headers["If-Modified-Since"]).present?
      begin
        validated_since = Time.httpdate(modified_since) >= last_modified
      rescue ArgumentError
        validated_since = false
      end
    end

    matches_etag || validated_since
  end
end
