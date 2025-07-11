import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number
  }

  connect() {
    this.ensureGoogleLoaded().then(() => {
      const center = {
        lat: this.latValue || 52.2297,
        lng: this.lngValue || 21.0122
      }

      this.map = new google.maps.Map(this.element, {
        center,
        zoom: 13
      })

      new google.maps.Marker({
        position: center,
        map: this.map
      })
    })
  }

  ensureGoogleLoaded() {
    return new Promise((resolve) => {
      if (window.google && window.google.maps) {
        resolve()
      } else {
        const check = setInterval(() => {
          if (window.google && window.google.maps) {
            clearInterval(check)
            resolve()
          }
        }, 50)
      }
    })
  }
}
