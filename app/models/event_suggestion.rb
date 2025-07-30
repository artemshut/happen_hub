class EventSuggestion < ApplicationRecord
  has_many :likes, as: :likeable, dependent: :destroy

  belongs_to :event
  belongs_to :user

  enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected' }
end
