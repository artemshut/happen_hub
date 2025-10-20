class Like < ApplicationRecord
  ALLOWED_LIKEABLE_TYPES = {
    "EventSuggestion" => EventSuggestion
  }.freeze

  belongs_to :user
  belongs_to :likeable, polymorphic: true

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    [ "likeable", "user" ]
  end
end
