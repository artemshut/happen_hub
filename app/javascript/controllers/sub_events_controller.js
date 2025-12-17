import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "list", "template" ]
  static values = { index: Number }

  connect() {
    if (!this.hasIndexValue) {
      this.indexValue = this.listTarget.children.length
    }
  }

  add(event) {
    event.preventDefault()
    const template = this.templateTarget.innerHTML.trim()

    if (!template) return

    const content = template.replace(/__INDEX__/g, this.indexValue)
    this.indexValue += 1

    const element = document.createElement("div")
    element.innerHTML = content
    const node = element.firstElementChild
    if (!node) return

    this.listTarget.appendChild(node)
    this.dispatch("added", { detail: { element: node } })
  }

  remove(event) {
    event.preventDefault()
    const wrapper = event.target.closest("[data-sub-events-wrapper]")
    if (!wrapper) return

    const destroyInput = wrapper.querySelector("input[name*='[_destroy]']")
    if (destroyInput) {
      destroyInput.value = "1"
      wrapper.classList.add("opacity-40")
      wrapper.style.display = "none"
    } else {
      wrapper.remove()
    }
    this.dispatch("removed", { detail: { element: wrapper } })
  }
}
