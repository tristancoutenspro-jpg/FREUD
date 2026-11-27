import { Controller } from "@hotwired/stimulus"

// Types the therapist's words out one character at a time. Click or tap the box to show everything at once.
// The not-yet-typed text stays in the page (invisible) so the box never changes size while typing.
export default class extends Controller {
  static targets = ["text"]
  static values = { animate: Boolean }

  connect() {
    this.running = false
    if (!this.animateValue || this.prefersReducedMotion()) {
      this.dispatch("done") // lets the room know nobody is talking
      return
    }
    this.begin()
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  begin() {
    this.segments = []
    const walker = document.createTreeWalker(this.textTarget, NodeFilter.SHOW_TEXT)
    const nodes = []
    while (walker.nextNode()) nodes.push(walker.currentNode)

    nodes.forEach((node) => {
      const full = node.nodeValue
      if (!full.trim()) return // whitespace between paragraphs
      const shown = document.createElement("span")
      const hidden = document.createElement("span")
      hidden.className = "tw-hidden"
      hidden.textContent = full
      node.replaceWith(shown, hidden)
      this.segments.push({ shown, hidden, full, index: 0 })
    })

    const total = this.segments.reduce((sum, segment) => sum + segment.full.length, 0)
    if (total === 0) return this.finish()

    this.perChar = Math.min(28, 7000 / total) // long answers speed up so nobody waits forever
    this.current = 0
    this.running = true
    this.dispatch("start")
    this.tick()
  }

  tick() {
    const segment = this.segments[this.current]
    if (!segment) return this.finish()

    const char = segment.full[segment.index]
    segment.index += 1
    segment.shown.textContent = segment.full.slice(0, segment.index)
    segment.hidden.textContent = segment.full.slice(segment.index)
    if (segment.index >= segment.full.length) this.current += 1

    this.followCursor(segment)
    this.timer = setTimeout(() => this.tick(), this.delayFor(char))
  }

  delayFor(char) {
    if (".!?…".includes(char)) return this.perChar * 6
    if (",;:—".includes(char)) return this.perChar * 3
    return this.perChar
  }

  // keeps the newest line in view when the box is scrollable (desktop overlay)
  followCursor(segment) {
    const box = this.textTarget
    if (box.scrollHeight <= box.clientHeight + 1) return

    const typing = segment.index < segment.full.length
    const rects = (typing ? segment.hidden : segment.shown).getClientRects()
    const rect = typing ? rects[0] : rects[rects.length - 1]
    if (!rect) return

    const overflow = rect.bottom - box.getBoundingClientRect().bottom + 6
    if (overflow > 0) box.scrollTop += overflow
  }

  skip() {
    if (this.running) this.finish()
  }

  finish() {
    clearTimeout(this.timer)
    this.running = false
    ;(this.segments || []).forEach((segment) => {
      segment.shown.textContent = segment.full
      segment.hidden.remove()
    })
    this.dispatch("done")
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
