class PlanSerializer
  include JSONAPI::Serializer

  attributes :name,
             :key,
             :tagline,
             :monthly_price_cents,
             :annual_price_cents,
             :max_active_events,
             :highlighted,
             :priority,
             :features

  attribute :unlimited_events do |plan|
    plan.unlimited_events?
  end

  attribute :display_price do |plan|
    if plan.monthly_price_cents.to_i.zero?
      "Free"
    else
      format("$%<price>.0f/mo", price: plan.price_per_month)
    end
  end

  attribute :is_current_plan do |plan, params|
    params && plan.id == params[:current_plan_id]
  end
end
