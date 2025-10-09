class Group < ApplicationRecord
  belongs_to :creator, class_name: "User", foreign_key: "user_id"
  has_many :events
  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user

  validates :name, presence: true

  scope :visible_to, lambda { |user|
    unless user
      where("1 = 0")
    else
      group_member_table = GroupMembership.arel_table
      group_table = arel_table

      membership_subquery = group_member_table.project(:group_id).where(group_member_table[:user_id].eq(user.id))
      condition = group_table[:user_id].eq(user.id).or(group_table[:id].in(membership_subquery))

      where(condition)
    end
  }

  def add_friend(user)
    group_memberships.create(user: user)
  end
end
