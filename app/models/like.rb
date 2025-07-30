class Like < ApplicationRecord
  ALLOWED_LIKEABLE_TYPES = {
    "EventSuggestion" => EventSuggestion,
  }.freeze

  belongs_to :user
  belongs_to :likeable, polymorphic: true
end
