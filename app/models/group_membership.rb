class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

  # ActiveAdmin Ransackable Associations and Attributes
  def self.ransackable_associations(auth_object = nil)
    [ "group", "user" ]
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "group_id", "id", "updated_at", "user_id" ]
  end
end
