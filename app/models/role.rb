class Role < ApplicationRecord
  has_many :role_assignments, dependent: :destroy
  has_many :users, through: :role_assignments

  validates :name, presence: true
  validates :key, presence: true, uniqueness: true

  DEFAULT_KEYS = %w[admin organizer moderator member].freeze
end
