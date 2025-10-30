import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "dialog"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.isOpen = false
  }

  open(event) {
    event.preventDefault()
    if (this.isOpen) return

    this.toggle(true)
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.isOpen) return

    this.toggle(false)
  }

  stop(event) {
    event.stopPropagation()
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  toggle(state) {
    this.isOpen = state
    if (state) {
      this.backdropTarget.classList.remove("hidden")
      this.backdropTarget.classList.add("flex", "opacity-100")
      document.body.classList.add("overflow-hidden")
      document.addEventListener("keydown", this.boundHandleKeydown)
      this.dialogTarget.setAttribute("aria-modal", "true")
      this.dialogTarget.setAttribute("role", "dialog")
    } else {
      this.backdropTarget.classList.add("hidden")
      this.backdropTarget.classList.remove("flex", "opacity-100")
      document.body.classList.remove("overflow-hidden")
      document.removeEventListener("keydown", this.boundHandleKeydown)
      this.dialogTarget.removeAttribute("aria-modal")
      this.dialogTarget.removeAttribute("role")
    }
  }
}
