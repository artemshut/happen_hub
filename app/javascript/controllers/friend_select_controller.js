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
    this.boxTarget.classList.remove("bg-green-100", "border-green-500", "bg-white", "border-gray-300", "ring-2", "ring-red-400")

    if (selected) {
      this.boxTarget.classList.add("bg-green-100", "border-green-500")
    } else {
      this.boxTarget.classList.add("bg-white", "border-gray-300", "ring-2", "ring-red-400")
    }
  }
}
