# frozen_string_literal: true

class UserMissionSerializer
  include JSONAPI::Serializer

  set_type :user_mission

  attributes :status, :progress, :target_value, :expires_at, :completed_at, :created_at

  attribute :mission do |user_mission|
    mission = user_mission.mission
    {
      key: mission.key,
      title: mission.title,
      description: mission.description_text,
      category: mission.category,
      reward_xp: mission.reward_xp,
      reward_badge: mission.reward_badge
    }
  end

  attribute :progress_ratio do |user_mission|
    user_mission.progress_ratio
  end
end
