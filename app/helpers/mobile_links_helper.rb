# frozen_string_literal: true

module MobileLinksHelper
  def native_event_deep_link(event)
    scheme = mobile_app_scheme
    return if scheme.blank? || event.blank?

    "#{scheme}://events/#{event.share_token}"
  end

  def ios_app_store_link
    Rails.application.credentials.dig(:mobile, :ios_store_url)
  end

  def android_play_store_link
    Rails.application.credentials.dig(:mobile, :android_store_url)
  end

  private

  def mobile_app_scheme
    Rails.application.credentials.dig(:mobile, :app_scheme).presence || "happenhub"
  end
end
