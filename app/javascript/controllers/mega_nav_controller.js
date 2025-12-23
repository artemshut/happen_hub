import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "dialog", "backdrop", "section", "trigger"]

  connect() {
    this.open = false
    this.boundCloseOnEscape = this.closeOnEscape.bind(this)
    this.boundHandleOutsideClick = this.handleOutsideClick.bind(this)
    this.boundCloseAll = () => this.close()
    window.addEventListener("mega-nav:closeAll", this.boundCloseAll)
  }

  toggle(event) {
    event.preventDefault()
    const trigger = event.currentTarget
    const targetSlug = trigger.dataset.section

    if (this.open && this.activeTrigger === trigger) {
      this.close()
      return
    }

    if (!this.open) {
      this.openMenu(trigger)
    } else {
      this.activeTrigger = trigger
    }

    if (targetSlug) {
      this.activateSection(targetSlug)
    }
  }

  openMenu(trigger) {
    this.open = true
    this.activeTrigger = trigger
    window.dispatchEvent(new CustomEvent("dropdown:closeAll"))
    this.backdropTarget.classList.remove("hidden")
    this.dialogTarget.classList.remove("pointer-events-none", "opacity-0", "-translate-y-4")
    this.dialogTarget.classList.add("opacity-100", "translate-y-0")
    document.addEventListener("keydown", this.boundCloseOnEscape)
    document.addEventListener("click", this.boundHandleOutsideClick, true)
  }

  close(event) {
    if (event) event.preventDefault()
    this.open = false
    this.backdropTarget.classList.add("hidden")
    this.dialogTarget.classList.add("pointer-events-none", "opacity-0", "-translate-y-4")
    this.dialogTarget.classList.remove("opacity-100", "translate-y-0")
    document.removeEventListener("keydown", this.boundCloseOnEscape)
    document.removeEventListener("click", this.boundHandleOutsideClick, true)
    if (this.activeTrigger) {
      this.activeTrigger.focus()
    }
    this.clearActiveStates()
  }

  disconnect() {
    window.removeEventListener("mega-nav:closeAll", this.boundCloseAll)
    document.removeEventListener("keydown", this.boundCloseOnEscape)
    document.removeEventListener("click", this.boundHandleOutsideClick, true)
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  handleOutsideClick(event) {
    if (!this.open) return
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  showSection(event) {
    event.preventDefault()
    const targetSlug = event.currentTarget.dataset.section
    this.activateSection(targetSlug)
  }

  activateSection(targetSlug) {
    if (!targetSlug) return

    this.toggleTargets.forEach((toggle) => {
      if (toggle.dataset.section === targetSlug) {
        toggle.classList.add("nav-trigger--active")
      } else {
        toggle.classList.remove("nav-trigger--active")
      }
    })

    this.triggerTargets.forEach((trigger) => {
      if (trigger.dataset.section === targetSlug) {
        trigger.classList.add("text-white", "bg-white/10")
        trigger.classList.remove("text-white/60")
      } else {
        trigger.classList.remove("text-white", "bg-white/10")
        trigger.classList.add("text-white/60")
      }
    })

    this.sectionTargets.forEach((section) => {
      section.classList.toggle("hidden", section.dataset.section !== targetSlug)
    })
  }

  clearActiveStates() {
    this.toggleTargets.forEach((toggle) => toggle.classList.remove("nav-trigger--active"))
    this.triggerTargets.forEach((trigger) => {
      trigger.classList.remove("text-white", "bg-white/10")
      trigger.classList.add("text-white/60")
    })
    this.sectionTargets.forEach((section) => section.classList.add("hidden"))
  }

  backdropClick(event) {
    if (!this.dialogTarget.contains(event.target)) {
      this.close()
    }
  }
}
