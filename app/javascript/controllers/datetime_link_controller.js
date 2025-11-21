import { Controller } from "@hotwired/stimulus"

const DATE_FORMAT = "Y-m-d H:i"
const DISPLAY_FORMAT = "F j, Y h:i K"
const MINUTE_INCREMENT = 15

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    if (!window.flatpickr) return
    this.initializePickers()
  }

  disconnect() {
    this.startPicker?.destroy()
    this.endPicker?.destroy()
  }

  initializePickers() {
    const now = this.roundToIncrement(new Date())

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
