// app/javascript/controllers/image_cropper_controller.js
import { Controller } from "@hotwired/stimulus"
import Cropper from "cropperjs"

export default class extends Controller {
  static targets = ["preview"]

  connect() {
    this.cropper = null

    window.addEventListener("avatar:fileSelected", (e) => {
      const { url } = e.detail
      this.previewTarget.src = url
      this.element.classList.remove("hidden")

      if (this.cropper) this.cropper.destroy()

      this.cropper = new Cropper(this.previewTarget, {
        aspectRatio: 1,
        viewMode: 1,
        autoCropArea: 1,
        scalable: false,
        movable: true,
        zoomable: true,
      })
    })
  }

  crop() {
    const canvas = this.cropper.getCroppedCanvas({
      width: 300,
      height: 300,
    })

    canvas.toBlob((blob) => {
      const event = new CustomEvent("avatar:cropped", { detail: { blob } })
      window.dispatchEvent(event)
      this.close()
    }, "image/jpeg")
  }

  cancel() {
    this.close()
  }

  close() {
    this.element.classList.add("hidden")
    if (this.cropper) this.cropper.destroy()
    this.previewTarget.src = ""
  }
}
