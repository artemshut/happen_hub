# frozen_string_literal: true

module Missions
  class ProgressService
    def initialize(user)
      @user = user
    end

    def tick!(mission_key, increment: 1, metadata: {}, expires_at: nil)
      mission = Mission.active.find_by(key: mission_key.to_s)
      return unless mission

      assignment = find_or_assign_mission(mission, expires_at: expires_at)
      assignment.increment!(increment, metadata: metadata)
      assignment
    end

    private

    def find_or_assign_mission(mission, expires_at: nil)
      current = @user.user_missions.active.find_by(mission_id: mission.id)
      return current if current

      mission.user_missions.create!(
        user: @user,
        target_value: mission.target_value,
        status: :pending,
        expires_at: expires_at
      )
    end
  end
end
