import { Controller } from "@hotwired/stimulus"

// Toggles visibility for a section while updating button labels
export default class extends Controller {
  static targets = [ "body", "label" ]
  static values = {
    expandedText: { type: String, default: "Hide section" },
    collapsedText: { type: String, default: "Show section" },
    collapsed: { type: Boolean, default: false }
  }

  connect() {
    this.applyState()
  }

  toggle(event) {
    event?.preventDefault()
    this.collapsedValue = !this.collapsedValue
    this.applyState()
  }

  applyState() {
    this.bodyTargets.forEach((element) => {
      element.style.display = this.collapsedValue ? "none" : ""
    })

    if (this.hasLabelTarget) {
      this.labelTarget.textContent = this.collapsedValue ? this.collapsedTextValue : this.expandedTextValue
    }
  }
}
