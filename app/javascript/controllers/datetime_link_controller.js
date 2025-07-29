import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["start", "end"]

  connect() {
    // optional: console.log("DatetimeLinkController connected")
  }

  handleStartChange() {
    if (this.startTarget.value) {
      setTimeout(() => {
        this.endTarget.focus()
        this.endTarget.showPicker?.() // for browsers that support it
      }, 100)
    }
  }
}
