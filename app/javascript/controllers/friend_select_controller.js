import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["box", "input"]

  connect() {
    this.toggleVisual(this.inputTarget.checked)
  }

  toggle() {
    const selected = !this.inputTarget.checked
    this.inputTarget.checked = selected
    this.toggleVisual(selected)
  }

  toggleVisual(selected) {
    this.boxTarget.dataset.selected = selected ? "true" : "false"
  }
}
