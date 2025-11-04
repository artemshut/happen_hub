import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    trackUrl: String,
    title: String,
    text: String
  }

  static targets = [ "feedback" ]

  copy(event) {
    event.preventDefault()
    if (!this.hasUrlValue) return

    navigator.clipboard.writeText(this.urlValue)
      .then(() => this.showFeedback("Link copied"))
      .catch(() => this.showFeedback("Unable to copy", true))
      .finally(() => this.trackShare())
  }

  nativeShare(event) {
    event.preventDefault()
    if (!navigator.share) {
      this.copy(event)
      return
    }

    navigator.share({
      title: this.titleValue || "You're invited!",
      text: this.textValue || "Join me on HappenHub",
      url: this.urlValue
    })
      .then(() => this.showFeedback("Shared!"))
      .catch(() => {})
      .finally(() => this.trackShare())
  }

  showFeedback(message, isError = false) {
    if (!this.hasFeedbackTarget) return
    this.feedbackTarget.textContent = message
    this.feedbackTarget.dataset.state = isError ? "error" : "success"
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.feedbackTarget.textContent = ""
      this.feedbackTarget.dataset.state = ""
    }, 2000)
  }

  trackShare() {
    if (!this.hasTrackUrlValue) return

    const headers = { "Accept": "application/json" }
    const token = document.querySelector("meta[name='csrf-token']")?.content
    if (token) headers["X-CSRF-Token"] = token

    fetch(this.trackUrlValue, {
      method: "POST",
      headers
    }).catch(() => {})
  }
}
