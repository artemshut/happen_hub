import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "overlay"]

  connect() {
    this.open = false
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
  }

  toggle() {
    this.open ? this.close() : this.openMenu()
  }

  openMenu() {
    this.open = true
    this.panelTarget.classList.remove("translate-x-full")
    this.panelTarget.classList.add("translate-x-0")
    this.overlayTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    document.addEventListener("keydown", this.boundCloseOnEscape)
  }

  close() {
    this.open = false
    this.panelTarget.classList.add("translate-x-full")
    this.panelTarget.classList.remove("translate-x-0")
    this.overlayTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.boundCloseOnEscape)
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
