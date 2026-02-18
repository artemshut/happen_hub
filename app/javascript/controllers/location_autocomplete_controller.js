import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "lat", "lng"]

  connect() {
    if (!window.google || !window.google.maps || !window.google.maps.places) {
      console.error("Google Maps Places API not loaded");
      return;
    }

    this.autocomplete = new google.maps.places.Autocomplete(this.inputTarget, {
      types: ["establishment"]
    })

    this.autocomplete.addListener("place_changed", () => {
      const place = this.autocomplete.getPlace()

      if (!place.geometry) return

      const location = place.geometry.location
      if (this.hasLatTarget) this.latTarget.value = location.lat()
      if (this.hasLngTarget) this.lngTarget.value = location.lng()
    })
  }
}
