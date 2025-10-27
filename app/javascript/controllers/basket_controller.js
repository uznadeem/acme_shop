// app/javascript/controllers/basket_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["qty", "subtotal", "discount", "delivery", "total", "row", "lineTotal"]

  connect() {
    this.recalc()
  }

  debouncedRecalc() {
    clearTimeout(this._t)
    this._t = setTimeout(() => this.recalc(), 250)
  }

  async recalc() {
    try {
      const formData = new FormData(this.element) // controller is on the <form>
      const res = await fetch("/basket/calculate", {
        method: "POST",
        headers: { "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content },
        body: formData
      })
      if (!res.ok) throw new Error(`HTTP ${res.status}`)
      const data = await res.json()

      // Totals
      this.subtotalTarget.textContent = this.money(Math.round(data.subtotal * 100))
      this.discountTarget.textContent = "-" + this.money(Math.round(data.discount * 100))
      this.deliveryTarget.textContent = this.money(Math.round(data.delivery * 100))
      this.totalTarget.textContent    = this.money(Math.round(data.total * 100))

      // Line totals by product_id
      const lines = data.lines || {}
      this.rowTargets.forEach((row) => {
        const pid = row.dataset.productId
        const cents = lines[pid] || 0
        const cell = row.querySelector("[data-basket-target='lineTotal']")
        if (cell) cell.textContent = this.money(cents)
      })
    } catch (e) {
      console.error("Recalc failed:", e)
    }
  }

  money(cents) {
    return new Intl.NumberFormat(undefined, { style: "currency", currency: "USD" })
      .format((cents || 0) / 100.0)
  }
}
