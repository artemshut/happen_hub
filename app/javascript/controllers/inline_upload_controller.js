import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "fileInput", "fileList", "submit"]

  handleChange(event) {
    const files = Array.from(this.fileInputTarget.files || [])
    this.processFiles(files)
  }

  drop(event) {
    event.preventDefault()
    this.unhighlight()

    const files = Array.from(event.dataTransfer?.files || [])
    if (files.length === 0) return

    this.assignFiles(files)
    this.processFiles(files)
  }

  highlight(event) {
    event.preventDefault()
    this.element.classList.add("border-accent-pink", "bg-accent-pink/10")
  }

  unhighlight() {
    this.element.classList.remove("border-accent-pink", "bg-accent-pink/10")
  }

  processFiles(files) {
    if (files.length === 0) return

    this.renderFileList(files)
    this.submitForm()
  }

  processQueued() {
    const files = Array.from(this.fileInputTarget.files || [])
    this.processFiles(files)
  }

  renderFileList(files) {
    if (!this.hasFileListTarget) return

    const items = files
      .map((file) => `<li>${this.escapeHtml(file.name)} (${this.humanSize(file.size)})</li>`)
      .join("")

    this.fileListTarget.innerHTML = items
    this.fileListTarget.classList.remove("hidden")
  }

  assignFiles(files) {
    if (!this.hasFileInputTarget) return

    const dataTransfer = new DataTransfer()
    files.forEach((file) => dataTransfer.items.add(file))
    this.fileInputTarget.files = dataTransfer.files
  }

  submitForm() {
    const formElement = this.hasFormTarget ? this.formTarget : this.element

    if (typeof formElement.requestSubmit === "function") {
      formElement.requestSubmit()
    } else if (this.hasSubmitTarget) {
      this.submitTarget.click()
    }
  }

  humanSize(bytes) {
    if (!bytes || bytes <= 0) return "0 B"
    const units = ["B", "KB", "MB", "GB"]
    const index = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1)
    const value = bytes / Math.pow(1024, index)
    return `${value.toFixed(value >= 10 || index === 0 ? 0 : 1)} ${units[index]}`
  }

  escapeHtml(text = "") {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }
}
