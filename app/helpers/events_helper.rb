module EventsHelper
  BADGE_CLASSES = {
    "free" => "bg-green-100 text-green-800 border-green-200",
    "busy" => "bg-red-100 text-red-800 border-red-200",
    "tentative" => "bg-amber-100 text-amber-800 border-amber-200",
    "unknown" => "bg-gray-200 text-gray-700 border-gray-300"
  }.freeze

  def availability_badge(availability)
    availability ||= {}

    status = availability.fetch(:status, "unknown")
    label = status.capitalize
    classes = BADGE_CLASSES.fetch(status, BADGE_CLASSES["unknown"])
    tooltip = availability_badge_tooltip(availability)

    content_tag(
      :span,
      label,
      class: "inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold border #{classes}",
      title: tooltip.presence
    )
  end

  private

  def availability_badge_tooltip(availability)
    return availability[:note] if availability[:note].present?

    conflicts = availability.fetch(:conflicts, [])
    return if conflicts.blank?

    conflicts.map do |conflict|
      title = conflict[:title]
      start_time = conflict[:start_time]
      time_str = start_time.respond_to?(:in_time_zone) ? I18n.l(start_time.in_time_zone, format: :short) : start_time.to_s
      "#{title} (#{time_str})"
    end.join("\n")
  end
end
