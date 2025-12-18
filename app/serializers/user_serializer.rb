# app/serializers/user_serializer.rb
class UserSerializer
  include JSONAPI::Serializer

  attributes :id, :email, :first_name, :last_name, :username, :tag, :fcm_token, :xp, :cosmetic_unlocks

  attribute :avatar_url do |user|
    if user.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(
        user.avatar,
        host: "happenhub.co",
      )
    end
  end

  attribute :plan do |user|
    plan = user.plan
    next unless plan

    {
      id: plan.id,
      key: plan.key,
      name: plan.name,
      tagline: plan.tagline,
      highlighted: plan.highlighted,
      max_active_events: plan.max_active_events,
      unlimited_events: plan.unlimited_events?,
      monthly_price_cents: plan.monthly_price_cents,
      annual_price_cents: plan.annual_price_cents,
      features: plan.feature_list,
      priority: plan.priority,
      active_events_count: user.active_events_count,
      events_remaining: plan.unlimited_events? ? nil : user.events_remaining_on_plan,
      can_create_event: user.can_create_event?
    }
  end
end
