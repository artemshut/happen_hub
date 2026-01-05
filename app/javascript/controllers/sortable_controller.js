import { Controller } from "@hotwired/stimulus"

// Enables drag-and-drop sorting for checklists and checklist items.
export default class extends Controller {
  static values = {
    itemSelector: { type: String, default: "[data-sortable-item]" }
  }

  connect() {
    this.dragged = null
  }

  dragstart(event) {
    const item = this.sortableItemFrom(event)
    if (!item) return

    this.dragged = item
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", "")
    item.classList.add("opacity-50")
  }

  dragover(event) {
    if (!this.dragged) return
    const target = this.sortableItemFrom(event)
    if (!target || target === this.dragged || target.parentElement !== this.dragged.parentElement) return

    event.preventDefault()
    const bounding = target.getBoundingClientRect()
    const offset = event.clientY - bounding.top
    const half = bounding.height / 2
    if (offset > half) {
      target.after(this.dragged)
    } else {
      target.before(this.dragged)
    }
  }

  drop(event) {
    if (this.dragged) {
      event.preventDefault()
    }
  }

  dragend() {
    if (!this.dragged) return

    this.dragged.classList.remove("opacity-50")
    const items = Array.from(this.element.querySelectorAll(this.itemSelectorValue))
    const position = items.indexOf(this.dragged) + 1
    const url = this.dragged.dataset.reorderUrl

    if (url && position > 0) {
      this.submitReorder(url, position)
    }

    this.dragged = null
  }

  submitReorder(url, position) {
    fetch(url, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": this.csrfToken,
        "Accept": "text/vnd.turbo-stream.html",
        "Content-Type": "application/x-www-form-urlencoded"
      },
      body: new URLSearchParams({ position }).toString()
    })
  }

  sortableItemFrom(event) {
    const selector = this.itemSelectorValue || "[data-sortable-item]"
    return event.target.closest(selector)
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
  }
}
