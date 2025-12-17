# frozen_string_literal: true

class UserMission < ApplicationRecord
  belongs_to :user
  belongs_to :mission

  enum :status, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    expired: "expired"
  }, validate: true

  scope :active, -> { where(status: [ :pending, :in_progress ]) }

  validates :target_value, numericality: { greater_than: 0 }
  validates :progress, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sync_target, on: :create

  def progress_ratio
    [ progress.to_f / target_value, 1.0 ].min
  end

  def increment!(value, metadata: {})
    return self if completed? || expired?

    new_progress = [ progress + value, target_value ].min
    new_status = new_progress.positive? ? :in_progress : :pending

    update!(
      progress: new_progress,
      status: new_status,
      metadata: (self.metadata || {}).merge(metadata)
    )

    complete! if new_progress >= target_value && !completed?
    self
  end

  def expire!
    update!(status: :expired, expires_at: Time.current)
  end

  private

  def complete!
    update!(status: :completed, completed_at: Time.current)
    Missions::RewardService.new(self).apply_rewards!
  end

  def sync_target
    self.target_value ||= mission&.target_value || 1
  end
end
