# frozen_string_literal: true

module Missions
  class RewardService
    def initialize(user_mission)
      @user_mission = user_mission
      @mission = user_mission.mission
      @user = user_mission.user
    end

    def apply_rewards!
      ActiveRecord::Base.transaction do
        grant_xp(@mission.reward_xp) if @mission.reward_xp.positive?
        unlock_badge(@mission.reward_badge) if @mission.reward_badge.present?
      end
    end

    private

    def grant_xp(amount)
      @user.increment!(:xp, amount)
    end

    def unlock_badge(badge_key)
      unlocks = @user.cosmetic_unlocks.deep_dup
      badges = unlocks.fetch("badges", [])
      return if badges.include?(badge_key)

      badges << badge_key
      unlocks["badges"] = badges
      @user.update!(cosmetic_unlocks: unlocks)
    end
  end
end
