import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  clear(event) {
    event.preventDefault()
    const frame = this.element.closest("turbo-frame")
    if (!frame) return

    frame.src = frame.dataset.defaultSrc || frame.dataset.defaultContent || ""
  }
}
