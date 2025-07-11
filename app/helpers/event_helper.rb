module EventsHelper
  def formatted_event_date(date)
    return "" unless date

    date.in_time_zone("Europe/Warsaw").strftime("%A, %B %e, %Y at %H:%M")
  end
end
