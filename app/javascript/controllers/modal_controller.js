import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "dialog", "close"]

  connect() {
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.boundBackdropClick = this.handleBackdropClick.bind(this)
    this.boundStopPropagation = this.stopPropagation.bind(this)
    this.boundClose = this.close.bind(this)
    this.isOpen = false
    this.inBody = false
    this.backdropElement = this.backdropTarget
    this.dialogElement = this.dialogTarget
    if (!this.placeholder) {
      this.placeholder = document.createComment("modal-placeholder")
      this.backdropElement.parentNode.insertBefore(this.placeholder, this.backdropElement)
    }
    this.backdropElement.addEventListener("click", this.boundBackdropClick)
    this.dialogElement.addEventListener("click", this.boundStopPropagation)
    this.closeTargets.forEach((btn) => btn.addEventListener("click", this.boundClose))
  }

  open(event) {
    event.preventDefault()
    if (this.isOpen) return

    this.openButton = event.currentTarget
    this.toggle(true)
  }

  close(event) {
    if (event) event.preventDefault()
    this.toggle(false)
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  handleBackdropClick(event) {
    // Only close when clicking actual backdrop, not when animation already closing
    if (event.target === this.backdropElement) {
      this.close(event)
    }
  }

  stopPropagation(event) {
    event.stopPropagation()
  }

  toggle(state) {
    const backdrop = this.backdropElement
    const dialog = this.dialogElement
    this.isOpen = state
    if (state) {
      this.moveToBody()
      backdrop.classList.remove("hidden", "opacity-0", "pointer-events-none")
      backdrop.classList.add("flex", "opacity-100", "pointer-events-auto")
      dialog.classList.remove("pointer-events-none", "opacity-0", "-translate-y-6")
      dialog.classList.add("opacity-100", "translate-y-0")
      document.body.classList.add("overflow-hidden")
      document.addEventListener("keydown", this.boundHandleKeydown)
      dialog.setAttribute("aria-modal", "true")
      dialog.setAttribute("role", "dialog")
    } else {
      backdrop.classList.remove("opacity-100", "pointer-events-auto")
      backdrop.classList.add("opacity-0", "pointer-events-none")
      dialog.classList.add("pointer-events-none", "opacity-0", "-translate-y-6")
      dialog.classList.remove("opacity-100", "translate-y-0")
      window.setTimeout(() => {
        if (!this.isOpen) {
          backdrop.classList.add("hidden")
          backdrop.classList.remove("flex")
          this.restoreToPlaceholder()
        }
      }, 200)
      document.body.classList.remove("overflow-hidden")
      document.removeEventListener("keydown", this.boundHandleKeydown)
      dialog.removeAttribute("aria-modal")
      dialog.removeAttribute("role")
      if (this.openButton) {
        this.openButton.focus()
      }
      this.element.dispatchEvent(new CustomEvent("modal:closed", { bubbles: true }))
    }
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundHandleKeydown)
    this.restoreToPlaceholder(true)
    this.backdropElement.removeEventListener("click", this.boundBackdropClick)
    this.dialogElement.removeEventListener("click", this.boundStopPropagation)
    this.closeTargets.forEach((btn) => btn.removeEventListener("click", this.boundClose))
    this.backdropElement.classList.add("hidden", "opacity-0", "pointer-events-none")
    this.backdropElement.classList.remove("flex", "opacity-100", "pointer-events-auto")
  }

  moveToBody() {
    if (this.inBody) return
    document.body.appendChild(this.backdropElement)
    this.inBody = true
  }

  restoreToPlaceholder(force = false) {
    if (!this.inBody && !force) return
    if (this.placeholder && this.placeholder.parentNode) {
      this.placeholder.parentNode.insertBefore(this.backdropElement, this.placeholder)
    }
    this.inBody = false
    if (force && this.placeholder) {
      this.placeholder.remove()
      this.placeholder = null
    }
  }
}
