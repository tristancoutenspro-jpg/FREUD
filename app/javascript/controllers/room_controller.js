import { Controller } from "@hotwired/stimulus"

const TIMES = ["night", "dawn", "day", "dusk"]

// Lives on the whole room page.
// - shows the sky that matches the real time of day (add ?time=dawn|day|dusk|night to the URL to preview one)
// - lets the therapist "talk" while the text is typing and "think" while waiting for the AI
export default class extends Controller {
  static targets = ["room"]

  connect() {
    this.applyTime()
    this.clock = setInterval(() => this.applyTime(), 60 * 1000)
    // only fade between skies after the first paint, so the page doesn't start on the wrong sky
    requestAnimationFrame(() => this.roomTarget.classList.add("is-ready"))
  }

  disconnect() {
    clearInterval(this.clock)
  }

  applyTime() {
    const forced = new URLSearchParams(window.location.search).get("time")
    const time = TIMES.includes(forced) ? forced : this.timeOfDay()
    if (this.roomTarget.dataset.time !== time) this.roomTarget.dataset.time = time
  }

  timeOfDay(date = new Date()) {
    const hour = date.getHours() + date.getMinutes() / 60
    if (hour >= 5.5 && hour < 8.5) return "dawn"
    if (hour >= 8.5 && hour < 17.5) return "day"
    if (hour >= 17.5 && hour < 20.5) return "dusk"
    return "night"
  }

  talk() {
    this.element.classList.add("is-talking")
  }

  hush() {
    this.element.classList.remove("is-talking")
  }

  think() {
    this.hush()
    this.element.classList.add("is-thinking")
  }

  unthink() {
    this.element.classList.remove("is-thinking")
  }
}
