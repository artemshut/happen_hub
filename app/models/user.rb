class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2]

  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :events, through: :groups
  has_many :friendships, dependent: :destroy
  has_many :event_participations, dependent: :destroy
  has_many :friends, through: :friendships, source: :friend

  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id"
  has_many :inverse_friends, through: :inverse_friendships, source: :user

  validates :email, presence: true, uniqueness: true
  validates :tag, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :birthday, presence: true

  before_validation :assign_unique_tag

  def full_name
    "#{first_name} #{last_name}"
  end

  def add_friend(friend)
    friendships.create(friend: friend, status: 'pending')
  end

  def accept_friendship(friend)
    friendship = friendships.find_by(friend: friend)
    friendship.update(status: 'accepted') if friendship
  end

  def decline_friendship(friend)
    friendship = friendships.find_by(friend: friend)
    friendship.update(status: 'declined') if friendship
  end

  def self.search_by_tag(query)
    where("tag ILIKE ?", "%#{query}%")
  end

  def pending_event_requests
    event_participations.where(rsvp_status: :pending)
  end

  def pending_friend_requests
    inverse_friendships.where(status: :pending)
  end

  private

  def assign_unique_tag
    self.tag = "#{first_name[0..2].downcase}-#{last_name[0..2].downcase}-#{SecureRandom.hex(2)}" if tag.blank?
  end
end