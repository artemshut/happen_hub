ActiveAdmin.register Plan do
  permit_params :name, :key, :tagline, :monthly_price_cents, :annual_price_cents,
                :max_active_events, :highlighted, :priority, features: []

  controller do
    def update(*args)
      normalize_features_param!
      super
    end

    def create(*args)
      normalize_features_param!
      super
    end

    private

    def normalize_features_param!
      return unless params[:plan]&.key?(:features)

      raw = params[:plan][:features]
      params[:plan][:features] =
        if raw.is_a?(Array)
          raw
        else
          raw.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)
        end
    end
  end

  index do
    selectable_column
    id_column
    column :name
    column :key
    column("Monthly") { |plan| number_to_currency(plan.price_per_month, precision: 0) }
    column("Event limit") { |plan| plan.unlimited_events? ? "Unlimited" : plan.max_active_events }
    column :priority
    column :highlighted
    actions
  end

  filter :name
  filter :key
  filter :highlighted
  filter :priority

  form do |f|
    f.inputs do
      f.input :name
      f.input :key
      f.input :tagline
      f.input :monthly_price_cents, label: "Monthly price (cents)"
      f.input :annual_price_cents, label: "Annual price (cents)"
      f.input :max_active_events
      f.input :priority
      f.input :highlighted
      f.input :features, as: :text, input_html: { value: f.object.feature_list.join("\n"), rows: 6 },
              hint: "One feature per line"
    end
    f.actions
  end
end
