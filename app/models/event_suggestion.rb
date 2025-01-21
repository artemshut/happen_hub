class EventSuggestion < ApplicationRecord
  belongs_to :event
  belongs_to :user

  enum :status, { pending: 'pending', approved: 'approved', rejected: 'rejected' }
end
