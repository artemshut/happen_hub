class EventChecklist < ApplicationRecord
  belongs_to :event, inverse_of: :checklists
  has_many :items, -> { order(position: :asc, created_at: :asc) }, class_name: "EventChecklistItem", dependent: :destroy, inverse_of: :event_checklist

  before_validation :assign_position, on: :create

  validates :title, presence: true, length: { maximum: 80 }

  scope :ordered, -> { order(position: :asc, created_at: :asc) }

  def reposition!(target_position)
    return unless event

    EventChecklist.transaction do
      ordered = event.checklists.ordered.to_a
      ordered.delete(self)

      target_index = [ target_position.to_i - 1, 0 ].max
      target_index = ordered.length if target_index > ordered.length
      ordered.insert(target_index, self)

      ordered.each_with_index do |checklist, index|
        checklist.update_column(:position, index + 1) if checklist.position != index + 1
      end
    end
  end

  private

  def assign_position
    return if position.present? && position.positive?

    self.position = (event&.checklists&.maximum(:position) || 0) + 1
  end
end
