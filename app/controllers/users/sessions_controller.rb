require "uri"

module Users
  class SessionsController < Devise::SessionsController
    def new
      stash_return_location
      super
    end

    private

    def stash_return_location
      raw_location = params[:return_to].presence || params.dig(resource_name, :return_to)
      return if raw_location.blank?

      parsed = begin
        URI.parse(raw_location)
      rescue URI::InvalidURIError
        nil
      end

      path = if parsed&.host.present?
        parsed.path.presence
      else
        raw_location
      end

      return unless path.present? && path.start_with?("/")

      store_location_for(resource_name, path)
    end
  end
end
