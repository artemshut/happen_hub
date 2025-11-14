class Plan < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  scope :ordered_for_display, -> { order(priority: :desc, monthly_price_cents: :asc) }

  validates :name, :key, presence: true
  validates :key, uniqueness: true
  validates :monthly_price_cents, :annual_price_cents,
            numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :max_active_events, numericality: { greater_than: 0 }, allow_nil: true

  before_validation :normalize_features

  def self.ransackable_attributes(auth_object = nil)
    [ "annual_price_cents", "created_at", "features", "highlighted", "id", "id_value", "key", "max_active_events", "monthly_price_cents", "name", "priority", "tagline", "updated_at" ]
  end


  def unlimited_events?
    max_active_events.nil?
  end

  def feature_list
    Array(features).reject(&:blank?)
  end

  def price_per_month
    monthly_price_cents.to_i / 100.0
  end

  def price_per_year
    annual_price_cents.to_i / 100.0
  end

  private

  def normalize_features
    self.features = feature_list
  end
end
