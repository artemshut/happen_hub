import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    // optional hook for future use
  }

  handleStartChange() {
    if (this.startTarget.value) {
      setTimeout(() => {
        this.endTarget.focus()
        this.endTarget.showPicker?.() // for browsers that support it
      }, 100)
    }

    this.dispatchAvailabilityUpdate()
  }

  handleEndChange() {
    this.dispatchAvailabilityUpdate()
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
}
