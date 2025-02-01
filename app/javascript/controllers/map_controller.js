import { Controller } from "@hotwired/stimulus";
import L from "leaflet";

export default class extends Controller {
  static targets = ["map"];

  connect() {
    const mapElement = this.mapTarget;

    // Remove previous map instance if it exists
    if (mapElement.dataset.mapInitialized === "true") {
      console.warn("Destroying previous map instance...");
      mapElement.innerHTML = ""; // Clear map tiles
    }
    mapElement.dataset.mapInitialized = "true";

    const lat = parseFloat(mapElement.dataset.lat);
    const lng = parseFloat(mapElement.dataset.lng);

    if (!lat || !lng) {
      console.error("Missing latitude or longitude for the map.");
      return;
    }

    // Set correct height for map container
    mapElement.style.height = "350px";

    // Initialize Leaflet map with proper settings
    this.map = L.map(mapElement, {
      preferCanvas: true, // Improves performance
      zoomControl: false
    }).setView([lat, lng], 13);

    // Add OpenStreetMap tiles
    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
      updateWhenIdle: false,
      updateWhenZooming: false
    }).addTo(this.map);

    // Add marker for event location
    L.marker([lat, lng]).addTo(this.map)
      .bindPopup("<b>Event Location</b>").openPopup();

    // Ensure Leaflet correctly resizes
    setTimeout(() => {
      this.map.invalidateSize();
      document.querySelectorAll(".leaflet-pane").forEach((el) => {
        el.style.transform = "none"; // Fix `translate3d` issues
      });
    }, 500);
  }
}
