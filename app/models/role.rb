class Role < ApplicationRecord
  has_many :role_assignments, dependent: :destroy
  has_many :users, through: :role_assignments

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  DEFAULT_KEYS = %w[admin organizer moderator member].freeze

  def self.ransackable_attributes(auth_object = nil)
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    [ "role_assignments", "users" ]
  end
end
