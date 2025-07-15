import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "arrow"]

  connect() {
    this.handleClickOutside = this.closeIfClickedOutside.bind(this)
    document.addEventListener("click", this.handleClickOutside)
    document.addEventListener("keydown", (e) => {
      if (e.key === "Escape") this.close()
    })
  }

  disconnect() {
    document.removeEventListener("click", this.handleClickOutside)
  }

  toggle(event) {
    event.stopPropagation()
    const menu = this.menuTarget
    const arrow = this.hasArrowTarget ? this.arrowTarget : null
    const isHidden = menu.classList.contains("hidden")

    if (isHidden) {
      menu.classList.remove("hidden")
      requestAnimationFrame(() => {
        menu.classList.remove("opacity-0", "scale-y-95")
      })
      if (arrow) arrow.classList.add("rotate-180")
    } else {
      menu.classList.add("opacity-0", "scale-y-95")
      setTimeout(() => {
        menu.classList.add("hidden")
      }, 200)
      if (arrow) arrow.classList.remove("rotate-180")
    }
  }

  closeIfClickedOutside(e) {
    if (!this.element.contains(e.target)) {
      this.close()
    }
  }

  close() {
    const menu = this.menuTarget
    const arrow = this.hasArrowTarget ? this.arrowTarget : null
    menu.classList.add("opacity-0", "scale-y-95")
    setTimeout(() => {
      menu.classList.add("hidden")
    }, 200)
    if (arrow) arrow.classList.remove("rotate-180")
  }
}
