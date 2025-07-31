class EventCategory < ApplicationRecord
  has_many :events, dependent: :nullify
end
