# frozen_string_literal: true

module Missions
  class SoundcheckService
    SOUND_CHECK_KEY = :soundcheck_ready

    def initialize(event)
      @event = event
      @user = event.user
    end

    def call
      return unless prerequisites_met?

      Missions::ProgressService.new(@user).tick!(SOUND_CHECK_KEY, increment: 1, metadata: { event_id: @event.id })
    end

    private

    def prerequisites_met?
      @event.cover_image.attached? &&
        @event.location.present? &&
        @event.sub_events.any? &&
        @event.description.present?
    end
  end
end
