import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label", "loading"]

  submit() {
    this.buttonTarget.disabled = true
    this.labelTarget.classList.add("hidden")
    this.loadingTarget.classList.remove("hidden")
  }
}
