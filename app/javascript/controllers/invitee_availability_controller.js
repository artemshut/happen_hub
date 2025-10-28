import { Controller } from "@hotwired/stimulus"

// Updates the friend invite list when event times change.
export default class extends Controller {
  static values = {
    url: String
  }

  refresh(event) {
    const params = new URLSearchParams()
    const detail = event?.detail || {}

    if (detail.startTime) params.append("start_time", detail.startTime)
    if (detail.endTime) params.append("end_time", detail.endTime)

    const requestUrl = params.toString() ? `${this.urlValue}?${params.toString()}` : this.urlValue

    fetch(requestUrl, {
      headers: { Accept: "text/vnd.turbo-stream.html" },
      credentials: "same-origin"
    })
  }
}
