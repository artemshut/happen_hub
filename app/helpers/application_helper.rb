module ApplicationHelper
  include RichTextHelper

  def flash_class(type)
    case type.to_sym
    when :notice
      "flash-notice"
    when :alert
      "flash-alert"
    when :info
      "flash-info"
    when :warning
      "flash-warning"
    else
      "flash-notice"
    end
  end

  def formatted_event_date(date)
    return "" unless date

    date.strftime("%A, %B %e, %Y at %H:%M")
  end

  def plan_limit_label(plan)
    return "Unlimited active events" if plan&.unlimited_events?
    return "" unless plan&.max_active_events

    "#{plan.max_active_events} active #{'event'.pluralize(plan.max_active_events)}"
  end

  def plan_price_label(plan)
    return "Free forever" if plan&.monthly_price_cents.to_i.zero?

    monthly = number_to_currency(plan.price_per_month, precision: 0)
    "#{monthly}/mo"
  end
end
