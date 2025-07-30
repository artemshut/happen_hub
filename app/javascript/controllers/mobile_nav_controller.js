import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "overlay"]

  toggle() {
    const menuOpen = this.menuTarget.classList.contains("translate-x-0")

    this.menuTarget.classList.toggle("translate-x-0")
    this.menuTarget.classList.toggle("-translate-x-full")

    this.overlayTarget.classList.toggle("opacity-0")
    this.overlayTarget.classList.toggle("opacity-100")
    this.overlayTarget.classList.toggle("pointer-events-none")
  }

  close() {
    this.menuTarget.classList.remove("translate-x-0")
    this.menuTarget.classList.add("-translate-x-full")

    this.overlayTarget.classList.add("opacity-0", "pointer-events-none")
    this.overlayTarget.classList.remove("opacity-100")
  }
}
