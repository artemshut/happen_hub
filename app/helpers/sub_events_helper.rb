module SubEventsHelper
  def sub_event_add_button_html(event)
    link_to "Add segment",
            new_event_sub_event_path(event),
            class: "chip-link--primary px-5 py-2 text-xs uppercase tracking-[0.35em]",
            data: { turbo_frame: "new_sub_event" }
  end
end
