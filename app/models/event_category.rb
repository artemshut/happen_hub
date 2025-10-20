class EventCategory < ApplicationRecord
  has_many :events, dependent: :nullify

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "description", "emoji", "id", "id_value", "name", "updated_at" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "events" ]
  end
end
