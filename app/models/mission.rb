# frozen_string_literal: true

class Mission < ApplicationRecord
  has_many :user_missions, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :by_key, ->(key) { find_by!(key: key.to_s) }
  scope :auto_assignable, -> { active.where(auto_assign: true) }

  CATEGORIES = %w[weekend soundcheck custom].freeze

  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :target_value, numericality: { greater_than: 0 }

  def description_text
    description.presence || metadata.fetch("description", "")
  end

  def as_json_for(user)
    assignment = user&.active_user_missions&.find { |um| um.mission_id == id }
    {
      key: key,
      title: title,
      description: description_text,
      category: category,
      target_value: target_value,
      reward_xp: reward_xp,
      reward_badge: reward_badge,
      auto_assign: auto_assign,
      active: active,
      user_mission: assignment&.as_json(except: [ :metadata ]),
      metadata: metadata
    }
  end

  def auto_assign?
    auto_assign
  end

  def assign_to(user, expires_at: nil)
    user_missions.create!(
      user: user,
      target_value: target_value,
      expires_at: expires_at
    )
  end
end
