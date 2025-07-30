class User < ApplicationRecord
  # Devise authentication
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, :confirmable, omniauth_providers: %i[google_oauth2]

  # ActiveStorage
  has_one_attached :avatar

  # Groups and Events
  has_many :group_memberships, dependent: :destroy
  has_many :created_groups, class_name: "Group", foreign_key: "user_id", inverse_of: :creator
  has_many :groups, through: :group_memberships
  has_many :events, through: :groups
  has_many :likes, dependent: :destroy

  # Friendships (outgoing)
  has_many :friendships, dependent: :destroy, inverse_of: :user
  has_many :sent_friend_requests, -> { where(friendships: { status: "pending" }) }, through: :friendships, source: :friend

  # Friendships (incoming)
  has_many :inverse_friendships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy
  has_many :received_friend_requests, -> { where(friendships: { status: "pending" }) }, through: :inverse_friendships, source: :user

  # Comments
  has_many :comments, dependent: :destroy

  # Event Participations
  has_many :event_participations, dependent: :destroy

  # ------------------------
  # Validations
  # ------------------------
  validates :email, presence: true, uniqueness: true
  validates :tag, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :birthday, presence: true
  validates :password, presence: true, if: -> { password.present? }
  validates :username, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9_]+\z/ }

  # ------------------------
  # Callbacks
  # ------------------------
  before_validation :assign_unique_tag, on: :create
  before_validation :generate_username, on: :create
  after_create :send_confirmation_instructions, unless: -> { confirmed? }

  # ------------------------
  # Instance Methods
  # ------------------------

  def full_name
    "#{first_name} #{last_name}"
  end
  

  def send_confirmation_instructions
    # generate token
    self.confirmation_token = Devise.friendly_token
    self.confirmation_sent_at = Time.current
    save(validate: false)

    # send email via Envelop
    UserMailer.send_confirmation_instructions(self).deliver_now
  end

  def friends
    friend_ids = friendships.where(status: "accepted").pluck(:friend_id) +
                 inverse_friendships.where(status: "accepted").pluck(:user_id)
    User.where(id: friend_ids)
  end

  def friends_with?(other_user)
    friendships.exists?(friend_id: other_user.id, status: "accepted") ||
      inverse_friendships.exists?(user_id: other_user.id, status: "accepted")
  end

  def friend_request_sent_to?(other_user)
    friendships.exists?(friend_id: other_user.id, status: "pending")
  end

  def send_friend_request_to(other_user)
    friendships.find_or_create_by(friend: other_user, status: "pending")
  end

  def accept_friendship(friend)
    inverse_friendships.find_by(user: friend, status: "pending")&.update(status: "accepted")
  end

  def decline_friendship(friend)
    inverse_friendships.find_by(user: friend, status: "pending")&.update(status: "declined")
  end

  def pending_event_requests
    event_participations.where(rsvp_status: :pending)
  end

  def pending_friend_requests
    inverse_friendships.where(status: :pending)
  end

  def upcoming_events
    Event
      .left_joins(:event_participations)
      .where(
        "events.user_id = :user_id OR (event_participations.user_id = :user_id AND event_participations.rsvp_status = :accepted)",
        user_id: id,
        accepted: "accepted",
      )
      .where("start_time > ?", Time.current)
      .distinct
      .order(:start_time)
  end

  # ------------------------
  # Class Methods
  # ------------------------

  def self.search_by_tag(query)
    where("tag ILIKE ?", "%#{query}%")
  end
  

  # ------------------------
  # Private Helpers
  # ------------------------

  private

  def assign_unique_tag
    self.tag ||= "#{first_name[0..2].downcase}-#{last_name[0..2].downcase}-#{SecureRandom.hex(2)}"
  end

  def generate_username
    return if username.present?

    base = full_name.parameterize.underscore.gsub(/[^a-z0-9_]/, '')
    candidate = base
    suffix = 1

    while User.exists?(username: candidate)
      candidate = "#{base}_#{suffix}"
      suffix += 1
    end

    self.username = candidate
  end
end
