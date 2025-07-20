import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "arrow"]

  connect() {
    this._closeAllHandler = () => this.close()
    this._clickOutsideHandler = (event) => {
      if (!this.element.contains(event.target)) {
        this.close()
      }
    }

    window.addEventListener("dropdown:closeAll", this._closeAllHandler)
    document.addEventListener("click", this._clickOutsideHandler)
  }

  disconnect() {
    window.removeEventListener("dropdown:closeAll", this._closeAllHandler)
    document.removeEventListener("click", this._clickOutsideHandler)
  }

  toggle() {
    const isOpen = this.menuTarget.classList.contains("scale-y-100")
    window.dispatchEvent(new CustomEvent("dropdown:closeAll"))
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden", "opacity-0", "scale-y-95")
    this.menuTarget.classList.add("block", "opacity-100", "scale-y-100")

    if (this.hasArrowTarget) {
      this.arrowTarget.classList.add("rotate-180")
    }
  }

  close() {
    this.menuTarget.classList.remove("block", "opacity-100", "scale-y-100")
    this.menuTarget.classList.add("hidden", "opacity-0", "scale-y-95")

    if (this.hasArrowTarget) {
      this.arrowTarget.classList.remove("rotate-180")
    }
  }
}
