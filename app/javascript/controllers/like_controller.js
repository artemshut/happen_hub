import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { liked: Boolean }
  static targets = ["icon"]

  toggle(event) {
    event.preventDefault()
    const form = this.element.querySelector("form")

    fetch(form.action, {
      method: form.dataset.method,
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
    })
  }
}
