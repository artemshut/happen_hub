import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Listen for cropped blob from modal
    window.addEventListener("avatar:cropped", this.uploadCropped.bind(this))
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const modal = document.getElementById("avatar-cropper-modal")
    const imageTag = modal.querySelector("[data-image-cropper-target='preview']")
    imageTag.src = URL.createObjectURL(file)
    modal.dataset.originalFile = file
    modal.classList.remove("hidden")
  }

  uploadCropped(event) {
    const blob = event.detail.blob
    const form = this.element

    const formData = new FormData(form)
    formData.set("user[cropped_avatar]", blob, "avatar.jpg")

    fetch(form.action, {
      method: form.method,
      body: formData
    }).then(() => {
      Turbo.visit(window.location.href)
    })
  }
}
