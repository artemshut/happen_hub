import { Controller } from "@hotwired/stimulus"

const DATE_FORMAT = "Y-m-d H:i"
const DISPLAY_FORMAT = "F j, Y h:i K"
const MINUTE_INCREMENT = 15

export default class extends Controller {
  static targets = ["start", "end", "subStart", "subEnd"]

  connect() {
    if (!window.flatpickr) return

    if (this.hasStartTarget && this.hasEndTarget) {
      this.initializeMainPickers()
    }

    if (this.hasSubStartTarget || this.hasSubEndTarget) {
      this.initSubPickers()
    }
  }

  disconnect() {
    this.startPicker?.destroy()
    this.endPicker?.destroy()
  }

  initializeMainPickers() {
    const now = this.roundToIncrement(new Date())

    if (!this.hasStartTarget || !this.hasEndTarget) return

    this.startPicker = window.flatpickr(this.startTarget, {
      enableTime: true,
      minuteIncrement: MINUTE_INCREMENT,
      dateFormat: DATE_FORMAT,
      altInput: true,
      altFormat: DISPLAY_FORMAT,
      defaultDate: this.startTarget.value || now,
      onChange: (selectedDates) => this.handleStartChange(selectedDates),
      onReady: (_, __, instance) => {
        if (!instance.input.value) {
          instance.setDate(now, false)
          this.syncEndFromStart(now, { openPicker: false })
        }
      }
    })

    const initialEnd =
      this.endTarget.value || this.startTarget.value || now

    this.endPicker = window.flatpickr(this.endTarget, {
      enableTime: true,
      minuteIncrement: MINUTE_INCREMENT,
      dateFormat: DATE_FORMAT,
      altInput: true,
      altFormat: DISPLAY_FORMAT,
      defaultDate: initialEnd,
      onChange: () => this.handleEndChange()
    })

    if (!this.endTarget.value && this.startTarget.value) {
      const parsed = this.parseDate(this.startTarget.value, this.startPicker)
      parsed && this.syncEndFromStart(parsed, { openPicker: false })
    }

  }

  initSubPickers() {
    this.subStartTargets.forEach((input) => {
      const wrapper = input.closest("[data-controller~='datetime-link']")
      const endInput = wrapper?.querySelector("[data-datetime-link-target='subEnd']")
      this.initializeSubPicker(input, endInput)
    })
  }

  connectSubEvent(event) {
    const element = event?.detail?.element
    if (!element) return

    const startInput = element.querySelector("[data-datetime-link-target='subStart']")
    const endInput = element.querySelector("[data-datetime-link-target='subEnd']")
    if (startInput) this.initializeSubPicker(startInput, endInput)
  }

  disconnectSubEvent(event) {
    const element = event?.detail?.element
    if (!element) return

    element.querySelectorAll("[data-datetime-link-target='subStart'], [data-datetime-link-target='subEnd']").forEach((input) => {
      input._flatpickr?.destroy()
    })
  }

  initializeSubPicker(startInput, endInput) {
    if (!window.flatpickr || !startInput) return

    const now = this.roundToIncrement(new Date())
    const startPicker = window.flatpickr(startInput, {
      enableTime: true,
      minuteIncrement: MINUTE_INCREMENT,
      dateFormat: DATE_FORMAT,
      altInput: true,
      altFormat: DISPLAY_FORMAT,
      defaultDate: startInput.value || now,
      onChange: (selectedDates) => {
        const selected = selectedDates?.[0]
        if (selected && endInput?._flatpickr) {
          endInput._flatpickr.setDate(selected, false)
        }
      },
      onReady: (_, __, instance) => {
        startInput.dataset.datetimeLinkPicker = "true"
        if (!instance.input.value) {
          instance.setDate(now, false)
          endInput?._flatpickr?.setDate(now, false)
        }
      }
    })

    if (endInput) {
      window.flatpickr(endInput, {
        enableTime: true,
        minuteIncrement: MINUTE_INCREMENT,
        dateFormat: DATE_FORMAT,
        altInput: true,
        altFormat: DISPLAY_FORMAT,
        defaultDate: endInput.value || startInput.value || now,
        onReady: () => {
          endInput.dataset.datetimeLinkPicker = "true"
        }
      })
    }
  }

  handleStartChange(selectedDates) {
    const selected = selectedDates?.[0]
    if (selected) {
      this.syncEndFromStart(selected, { openPicker: true })
    }
    this.dispatchAvailabilityUpdate()
  }

  handleEndChange() {
    this.dispatchAvailabilityUpdate()
  }

  syncEndFromStart(date, { openPicker } = { openPicker: true }) {
    if (!this.endPicker) return
    this.endPicker.setDate(date, false)
    if (openPicker) {
      this.endPicker.open()
    }
  }

  dispatchAvailabilityUpdate() {
    if (!(this.hasStartTarget && this.hasEndTarget)) return

    const detail = {
      startTime: this.startTarget.value,
      endTime: this.endTarget.value
    }

    this.element.dispatchEvent(
      new CustomEvent("availability:update", { detail, bubbles: true })
    )
  }

  parseDate(value, picker) {
    if (!value || !picker) return null
    return picker.parseDate(value, DATE_FORMAT)
  }

  roundToIncrement(date) {
    const ms = MINUTE_INCREMENT * 60 * 1000
    return new Date(Math.ceil(date.getTime() / ms) * ms)
  }
}
