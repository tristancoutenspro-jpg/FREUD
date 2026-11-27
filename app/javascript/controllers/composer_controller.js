import { Controller } from "@hotwired/stimulus"

// The quick replies and the message bar.
// While the AI is answering, the therapist shows a "listening..." state (see room_controller).
export default class extends Controller {
  static targets = ["form", "input"]
  static values = { refocus: Boolean }

  connect() {
    this.thinking = false
    // this composer was just swapped in by a Turbo Stream, so the answer has arrived
    this.dispatch("done")
    if (this.refocusValue) this.inputTarget.focus({ preventScroll: true })
  }

  disconnect() {
    clearTimeout(this.fallback)
  }

  // tapping a chip sends it straight away
  pick(event) {
    if (this.thinking) return
    this.inputTarget.value = event.params.text
    this.formTarget.requestSubmit()
  }

  // ignore empty messages and double sends
  guard(event) {
    if (this.thinking || this.inputTarget.value.trim() === "") event.preventDefault()
  }

  start() {
    this.thinking = true
    this.element.classList.add("is-thinking")
    this.inputTarget.readOnly = true
    this.dispatch("thinking")
  }

  end() {
    // The answer replaces this whole composer a moment later (create.turbo_stream.erb).
    // If that never happens (for example the network dropped), stop "thinking" ourselves.
    clearTimeout(this.fallback)
    this.fallback = setTimeout(() => this.stopThinking(), 600)
  }

  stopThinking() {
    this.thinking = false
    this.element.classList.remove("is-thinking")
    this.inputTarget.readOnly = false
    this.dispatch("done")
  }
}
