// app/javascript/controllers/avatar_upload_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    // 👇 This is the missing piece
    window.addEventListener("avatar:cropped", this.upload.bind(this))
  }


  choose(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  preview() {
    const file = this.inputTarget.files[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = () => {
      const url = reader.result
      const event = new CustomEvent("avatar:fileSelected", { detail: { url } })
      window.dispatchEvent(event)
    }
    reader.readAsDataURL(file)
  }

  upload(e) {
    const { blob } = e.detail
    if (!blob) return

    const formData = new FormData()
    formData.append("user[cropped_avatar]", blob)

    fetch("avatar", {
      method: "PATCH",
      body: formData,
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      }
    }).then(() => window.location.reload())
  }
}
