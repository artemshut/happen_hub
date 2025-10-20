require "open-uri"

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
  # has_many :events, through: :groups #why???
  # has_many :events, through: :created_groups
  has_many :owned_events, class_name: "Event", foreign_key: "user_id", inverse_of: :user
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
  has_many :role_assignments, dependent: :destroy
  has_many :roles, through: :role_assignments

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

  before_validation :assign_first_name_and_last_name, on: :create
  before_validation :assign_unique_tag, on: :create
  before_validation :assign_birthday, on: :create
  before_validation :generate_username, on: :create
  after_create :send_confirmation_instructions, unless: -> { confirmed? }
  after_create :assign_default_role

  def full_name
    "#{first_name} #{last_name}"
  end

  def self.from_mobile_omniauth(payload)
    user = where(email: payload["email"]).first_or_initialize

    user.provider = "google_oauth2"
    user.uid = payload["sub"]
    user.first_name ||= payload["given_name"]
    user.last_name ||= payload["family_name"]
    if payload["picture"].present?
      # Download and attach profile picture
      downloaded_image = URI.open(payload["picture"])
      user.avatar.attach(io: downloaded_image, filename: "avatar-#{user.email}.jpg")
    end
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.skip_confirmation! if user.respond_to?(:skip_confirmation)
    user.save!
    user
  end

  def self.from_omniauth(auth)
    user = where(email: auth.info.email).first_or_initialize

    user.provider = auth.provider
    user.uid = auth.uid
    user.first_name ||= auth.info.first_name
    user.last_name ||= auth.info.last_name
    if auth.info.image.present?
      # Download and attach profile picture
      downloaded_image = URI.open(auth.info.image)
      user.avatar.attach(io: downloaded_image, filename: "avatar-#{user.email}.jpg")
    end
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.skip_confirmation! if user.respond_to?(:skip_confirmation)
    user.save!
    user
  end

  def send_confirmation_instructions
    self.confirmation_token = Devise.friendly_token
    self.confirmation_sent_at = Time.current
    save(validate: false)

    # send email via Envelop
    UserMailer.send_confirmation_instructions(self).deliver_now unless provider == "google_oauth2"
  end

  def friends
    User.where(id: friend_ids)
  end

  def friend_ids
    (friendships.where(status: "accepted").pluck(:friend_id) +
      inverse_friendships.where(status: "accepted").pluck(:user_id)).uniq
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

  def has_role?(key, resource: nil)
    scope = role_assignments.joins(:role).where(roles: { key: key.to_s })
    scope = scope.for_resource(resource) if resource.present?
    scope.exists?
  end

  def grant_role!(key, resource: nil)
    role = Role.find_by!(key: key.to_s)
    role_assignments.find_or_create_by!(role:, resource:)
  end

  def revoke_role!(key, resource: nil)
    role = Role.find_by!(key: key.to_s)
    assignments = role_assignments.where(role:)
    assignments = assignments.for_resource(resource) if resource.present?
    assignments.destroy_all
  end

  def upcoming_events
    Event.upcoming_for(self)
  end

  def self.search_by_tag(query)
    where("tag ILIKE ?", "%#{query}%")
  end

  def self.ransackable_attributes(auth_object = nil)
    [ "birthday", "confirmation_sent_at", "confirmation_token", "confirmed_at", "created_at", "email", "encrypted_password", "fcm_token", "first_name", "id", "id_value", "last_name", "platform", "provider", "remember_created_at", "reset_password_sent_at", "reset_password_token", "tag", "uid", "unconfirmed_email", "updated_at", "username" ]
  end

  def self.ransackable_associations(auth_object = nil)
    reflect_on_all_associations.map(&:name)
  end

  private

  def assign_unique_tag
    self.tag ||= "#{first_name[0..2].downcase}-#{last_name[0..2].downcase}-#{SecureRandom.hex(2)}"
  end

  def assign_first_name_and_last_name
    return if first_name.present? && last_name.present?

    self.first_name = "User"
    self.last_name = "Default"
  end

  def assign_birthday
    if birthday.blank?
      self.birthday = Date.new(2000, 1, 1) # Default to a placeholder date if birthday is missing
    end
  end

  def generate_username
    return if username.present?

    base = full_name.parameterize.underscore.gsub(/[^a-z0-9_]/, "")
    candidate = base
    suffix = 1

    while User.exists?(username: candidate)
      candidate = "#{base}_#{suffix}"
      suffix += 1
    end

    self.username = candidate
  end

  def assign_default_role
    member_role = Role.find_by(key: "member")
    return unless member_role

    role_assignments.find_or_create_by(role: member_role)
  end
end
