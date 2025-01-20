class Group < ApplicationRecord
  belongs_to :user
  has_many :events
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  validates :name, presence: true

  def add_friend(user)
    group_memberships.create(user: user)
  end
end