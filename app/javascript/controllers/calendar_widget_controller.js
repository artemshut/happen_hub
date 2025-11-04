import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["eventList", "emptyState", "modal", "panel", "fullCalendar"]

  connect() {
    this.events = []
    this.calendar = null
    this.isModalOpen = false
    this.fetchEvents()
  }

  disconnect() {
    this.destroyCalendar()
  }

  async fetchEvents() {
    try {
      const response = await fetch("/api/events", {
        headers: { Accept: "application/json" },
        credentials: "same-origin"
      })

      if (!response.ok) throw new Error(`Calendar fetch failed: ${response.status}`)

      this.events = await response.json()
      this.renderToday()
      if (this.isModalOpen) this.refreshCalendar()
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error(error)
    }
  }

  renderToday() {
    const listEl = this.eventListTarget
    listEl.querySelectorAll(".calendar-today__item").forEach((el) => el.remove())

    const todayEvents = this.eventsForToday()

    if (todayEvents.length === 0) {
      this.emptyStateTarget.classList.remove("hidden")
      return
    }

    this.emptyStateTarget.classList.add("hidden")

    todayEvents.forEach((event) => {
      const li = document.createElement("li")
      li.className = "calendar-today__item"

      const meta = this.eventMeta(event)

      li.innerHTML = `
        <div class="calendar-today__time">${meta.timeRange}</div>
        <div class="space-y-1">
          <p class="text-base font-semibold text-neutral-text">${this.escape(event.title)}</p>
          <p class="calendar-today__meta">${meta.status}</p>
        </div>
      `

      li.addEventListener("click", () => {
        window.location.href = event.url
      })

      listEl.appendChild(li)
    })
  }

  openModal(event) {
    event?.preventDefault()
    if (this.isModalOpen) return

    this.modalTarget.classList.remove("hidden")
    requestAnimationFrame(() => {
      this.modalTarget.classList.add("is-visible")
      this.panelTarget.classList.add("calendar-modal__panel--visible")
    })

    this.initializeCalendar()
    this.isModalOpen = true
  }

  closeModal(event) {
    event?.preventDefault()
    if (!this.isModalOpen) return

    this.modalTarget.classList.remove("is-visible")
    this.panelTarget.classList.remove("calendar-modal__panel--visible")

    setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      this.destroyCalendar()
      this.isModalOpen = false
    }, 200)
  }

  backdropClick(event) {
    if (event.target === this.modalTarget) {
      this.closeModal(event)
    }
  }

  goToToday(event) {
    event?.preventDefault()
    if (this.calendar) {
      this.calendar.today()
    }
  }

  initializeCalendar() {
    if (this.calendar || !this.hasFullCalendarTarget) return

    this.calendar = new FullCalendar.Calendar(this.fullCalendarTarget, {
      plugins: [
        FullCalendar.globalPlugins[7], // dayGridPlugin
        FullCalendar.globalPlugins[6] // interactionPlugin
      ],
      initialView: "dayGridMonth",
      height: "auto",
      contentHeight: "auto",
      buttonText: {
        today: "Today",
        dayGridMonth: "Month",
        dayGridWeek: "Week",
        dayGridDay: "Day"
      },
      firstDay: 1,
      headerToolbar: {
        left: "prev,next",
        center: "title",
        right: "dayGridMonth,dayGridWeek,dayGridDay"
      },
      events: this.events,
      editable: false,
      selectable: true,
      eventDisplay: "block",
      dayMaxEventRows: true,
      navLinks: true,
      titleFormat: { year: "numeric", month: "long" },
      eventClick: (info) => {
        info.jsEvent.preventDefault()
        window.location.href = info.event.url
      },
      eventDidMount: (info) => {
        const color = info.event.extendedProps.color || "#9333EA"
        info.el.style.background = color
        info.el.classList.add("calendar-event")
      },
      dayCellDidMount: (info) => {
        info.el.classList.add("transition-colors", "duration-200")
      },
      dateClick: (info) => {
        window.location.href = `/events/new?start_date=${info.dateStr}`
      }
    })

    this.calendar.render()
  }

  refreshCalendar() {
    if (this.calendar) {
      this.calendar.removeAllEventSources()
      this.calendar.addEventSource(this.events)
    }
  }

  destroyCalendar() {
    if (this.calendar) {
      this.calendar.destroy()
      this.calendar = null
    }
  }

  eventsForToday() {
    const now = new Date()
    const start = new Date(now.getFullYear(), now.getMonth(), now.getDate())
    const end = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1)

    return this.events
      .filter((event) => {
        const startDate = new Date(event.start)
        return startDate >= start && startDate < end
      })
      .sort((a, b) => new Date(a.start) - new Date(b.start))
  }

  eventMeta(event) {
    const startDate = new Date(event.start)
    const endDate = event.end ? new Date(event.end) : null
    const locale = navigator.language || "en-US"

    const timeOptions = { hour: "numeric", minute: "2-digit" }
    const timeRange = endDate
      ? `${startDate.toLocaleTimeString(locale, timeOptions)} – ${endDate.toLocaleTimeString(locale, timeOptions)}`
      : startDate.toLocaleTimeString(locale, timeOptions)

    const status = event.extendedProps?.status
      ? statusLabel(status)
      : "No response yet"

    return { timeRange, status }
  }

  escape(value) {
    if (!value) return ""
    return value.replace(/[&<>"']/g, (char) => {
      const map = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#039;"
      }
      return map[char]
    })
  }
}

function statusLabel(status) {
  switch (status) {
    case "accepted":
      return "You’re going"
    case "maybe":
      return "Maybe attending"
    case "declined":
      return "Declined"
    default:
      return "Awaiting RSVP"
  }
}
