import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String,
    trackUrl: String,
    title: String,
    text: String,
    appUrl: String,
    iosStoreUrl: String,
    androidStoreUrl: String,
    autoOpen: { type: Boolean, default: true }
  }

  static targets = [ "feedback" ]

  connect() {
    this.visibilityHandler = this.handleVisibilityChange.bind(this)
    if (this.shouldAutoOpen()) {
      this.launchNative({ silent: true })
    }
  }

  disconnect() {
    this.clearFallback()
  }

  copy(event) {
    event.preventDefault()
    if (!this.hasUrlValue) return

    navigator.clipboard.writeText(this.urlValue)
      .then(() => this.showFeedback("Link copied"))
      .catch(() => this.showFeedback("Unable to copy", true))
      .finally(() => this.trackShare())
  }

  openNative(event) {
    event?.preventDefault()
    if (!this.hasAppUrlValue) {
      this.showFeedback("App link unavailable", true)
      return
    }

    if (!this.isMobile()) {
      window.location.href = this.appUrlValue
      return
    }

    this.showFeedback("Opening in app…")
    this.launchNative()
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

  shouldAutoOpen() {
    return this.autoOpenValue && this.hasAppUrlValue && this.isMobile()
  }

  launchNative({ silent = false } = {}) {
    if (!this.hasAppUrlValue) return

    this.startFallbackCountdown()
    if (this.isIOS()) {
      window.location.href = this.appUrlValue
    } else if (this.isAndroid()) {
      const iframe = document.createElement("iframe")
      iframe.style.display = "none"
      iframe.src = this.appUrlValue
      document.body.appendChild(iframe)
      this.iframeCleanup = window.setTimeout(() => iframe.remove(), 1500)
    } else if (!silent) {
      window.location.href = this.appUrlValue
    }
  }

  startFallbackCountdown() {
    this.clearFallback()
    if (!this.platformStoreUrl()) return

    this.fallbackTimeout = window.setTimeout(() => this.openStoreFallback(), 1600)
    document.addEventListener("visibilitychange", this.visibilityHandler, { passive: true })
  }

  clearFallback() {
    if (this.fallbackTimeout) {
      clearTimeout(this.fallbackTimeout)
      this.fallbackTimeout = null
    }
    if (this.iframeCleanup) {
      clearTimeout(this.iframeCleanup)
      this.iframeCleanup = null
    }
    document.removeEventListener("visibilitychange", this.visibilityHandler)
  }

  handleVisibilityChange() {
    if (document.visibilityState === "hidden") {
      this.clearFallback()
    }
  }

  openStoreFallback() {
    const fallback = this.platformStoreUrl()
    this.clearFallback()
    if (!fallback) return

    window.location.href = fallback
  }

  platformStoreUrl() {
    if (this.isIOS() && this.hasIosStoreUrlValue) return this.iosStoreUrlValue
    if (this.isAndroid() && this.hasAndroidStoreUrlValue) return this.androidStoreUrlValue
    return null
  }

  isMobile() {
    return /iphone|ipad|ipod|android/i.test(window.navigator.userAgent || "")
  }

  isIOS() {
    return /iphone|ipad|ipod/i.test(window.navigator.userAgent || "")
  }

  isAndroid() {
    return /android/i.test(window.navigator.userAgent || "")
  }
}
