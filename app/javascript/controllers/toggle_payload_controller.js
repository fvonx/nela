import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "plusIcon", "minusIcon"]

  toggle() {
    this.minusIconTarget.classList.toggle("hidden")
    this.plusIconTarget.classList.toggle("hidden")

    this.contentTarget.classList.toggle("hidden")
  }
}