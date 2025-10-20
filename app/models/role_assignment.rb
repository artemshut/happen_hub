class RoleAssignment < ApplicationRecord
  belongs_to :user
  belongs_to :role
  belongs_to :resource, polymorphic: true, optional: true

  validates :role_id, uniqueness: { scope: [ :user_id, :resource_type, :resource_id ] }

  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :for_resource, ->(resource) { where(resource: resource) }

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    [ "role", "user" ]
  end
end
