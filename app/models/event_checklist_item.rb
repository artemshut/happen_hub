class EventChecklistItem < ApplicationRecord
  belongs_to :event, inverse_of: :checklist_items
  belongs_to :event_checklist, inverse_of: :items
  belongs_to :assignee, class_name: "User", optional: true

  before_validation :assign_position, on: :create
  before_validation :sync_event_from_checklist
  before_save :sync_completed_at

  validates :title, presence: true, length: { maximum: 120 }

  scope :incomplete, -> { where(completed: false) }
  scope :completed, -> { where(completed: true) }

  def reposition!(target_position)
    EventChecklistItem.transaction do
      ordered = event_checklist.items.to_a
      ordered.delete(self)

      target_index = [ target_position.to_i - 1, 0 ].max
      target_index = ordered.length if target_index > ordered.length
      ordered.insert(target_index, self)

      ordered.each_with_index do |item, index|
        item.update_column(:position, index + 1) if item.position != index + 1
      end
    end
  end

  private

  def assign_position
    return if position.present? && position.positive?

    self.position = (event_checklist&.items&.maximum(:position) || 0) + 1
  end

  def sync_completed_at
    return unless will_save_change_to_completed?

    self.completed_at = completed? ? Time.current : nil
  end

  def sync_event_from_checklist
    self.event ||= event_checklist&.event
  end
end
