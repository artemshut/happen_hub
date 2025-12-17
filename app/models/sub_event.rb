# frozen_string_literal: true

class SubEvent < ApplicationRecord
  belongs_to :event

  default_scope { order(position: :asc, start_time: :asc, created_at: :asc) }

  validates :title, presence: true, length: { maximum: 120 }
  validate :chronological_times

  before_validation :assign_position

  def duration
    return unless start_time.present? && end_time.present?

    end_time - start_time
  end

  private

  def assign_position
    return if position.present?

    self.position = (event&.sub_events&.maximum(:position) || -1) + 1
  end

  def chronological_times
    return unless start_time.present? && end_time.present?
    return if end_time.after?(start_time)

    errors.add(:end_time, "must be after the start time")
  end
end
