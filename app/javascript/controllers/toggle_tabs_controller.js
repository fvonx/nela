import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["tabContent", "button"];

  connect() {
    this.toggleContent(0);
  }

  toggle(event) {
    const index = event.currentTarget.dataset.index;
    this.toggleContent(index);
  }

  toggleContent(index) {
    this.tabContentTargets.forEach((content, i) => {
      content.classList.toggle("hidden", i !== Number(index));
    });
  
    this.buttonTargets.forEach((button, i) => {
      // Active button
      button.classList.toggle("bg-gray-800", i === Number(index));
      button.classList.toggle("hover:bg-gray-950", i === Number(index));
      button.classList.toggle("text-white", i === Number(index));

      // Inactive button
      button.classList.toggle("text-gray-800", i !== Number(index));
      button.classList.toggle("bg-gray-100", i !== Number(index));
      button.classList.toggle("hover:bg-gray-200", i !== Number(index));
    });
  }
}