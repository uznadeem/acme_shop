# Acme Shop – Piktochart Fullstack Developer Coding Test

This repository contains the **Acme Shop** solution — a Ruby on Rails implementation of the [Piktochart Fullstack Developer Coding Challenge](https://docs.google.com/document/d/15lqdsAkygksBc-cDefDzLnCEXzi8kPseIW6cXO75bw4/edit?tab=t.0).
The task was to develop a **shopping basket system** for **Acme Widget Co**, a fictional company that sells widgets with **tiered delivery rules** and **dynamic promotional offers**.

The project goes beyond a console solution — it’s a fully functional web application with a live UI, instant recalculations, and complete test coverage.

<img width="605" height="383" alt="image" src="https://github.com/user-attachments/assets/e76d3d50-cdb7-44e6-9075-39da677518a2" />

## Challenge Summary

### Products

| Product | Code | Price |
|----------|------|--------|
| 🔴 Red Widget | R01 | $32.95 |
| 🟢 Green Widget | G01 | $24.95 |
| 🔵 Blue Widget | B01 | $7.95 |

### Delivery Rules

- Orders **under $50** → $4.95
- Orders **under $90** → $2.95
- Orders **$90 or more** → Free delivery

### Offer Rule

> **Buy one Red Widget (R01), get the second one at half price.**

### Example Expected Totals

| Basket | Expected Total |
|---------|----------------|
| B01, G01 | $37.85 |
| R01, R01 | $54.37 |
| R01, G01 | $60.85 |
| B01, B01, R01, R01, R01 | $98.27 |


## 🗄️ Database Schema

### Products
- code (string) — Product identifier like R01, G01, B01
- name (string) — Product name
- price_cents (integer) — Price stored in cents for precision

### DeliveryRules
- min_total_cents (integer) — Minimum basket total for the rule
- max_total_cents (integer, nullable) — Maximum basket total for the rule
- charge_cents (integer) — Delivery fee for that range

### Offers
- product_code (string) — Code of applicable product
- description (string) — Offer detail text
- discount_type (string) — Type (e.g., `bogo_half`)
- discount_value (decimal) — Value of discount (e.g., 50 for half price)

### Baskets
- id (integer)

### BasketItems
- basket_id (integer, FK)
- product_id (integer, FK)
- quantity (integer, default: 1)


## 🧠 Core Concepts

- **Basket Interface** – Allows adding products by code and computing totals dynamically.
- **Pricing Engine** – Centralized business logic for calculating subtotal, discounts, and delivery.
- **Offer Engine** – Abstracted design for applying current and future promotions flexibly.
- **AJAX Recalculation** – Real-time updates through Stimulus.js without reloading the page.
- **Bootstrap Layout** – Responsive and polished front-end for professional presentation.



## ⚙️ Tech Stack

| Component | Technology |
|------------|-------------|
| Language | Ruby 3.3.4 |
| Framework | Rails 7.2.1 |
| Database | PostgreSQL |
| Frontend | Bootstrap 5 + Stimulus.js |
| Currency | Money gem |
| Testing | Minitest |
| Background Processing | Built-in Rails Jobs |



## 🌱 Seed Data

Running the seed file populates:

- **Products:** R01, G01, B01
- **Offers:** Buy one Red Widget, get second half price
- **Delivery Rules:** $4.95, $2.95, $0 thresholds

Command:

`rails db:setup`



## 🚀 Setup Guide

**1. Clone Repository**
`git clone https://github.com/uznadeem/acme_shop.git && cd acme_shop`

**2. Install Dependencies**
`bundle install`

**3. Setup Database**
`rails db:create db:migrate db:seed`

**4. Run Server**
`rails s`

**5. Access Application**
Visit: [http://localhost:3000](http://localhost:3000)


## 🎨 Frontend Overview

The UI uses **Bootstrap 5** for structure and **Stimulus.js** for interactivity.

### Key Features
- Minimal layout with light background.
- Dynamic price recalculations via AJAX (`/basket/calculate`).
- Sticky order summary card that updates instantly.

---

## 🧮 Business Logic Overview

### Subtotal
Sum of all product prices × their respective quantities.

### Discount
Applied dynamically through active offers.
Currently supports `bogo_half` for Red Widgets — applies 50% off on every second item.

### Delivery Fee
Determined based on the **post-discount subtotal**:
- < $50 → $4.95
- < $90 → $2.95
- ≥ $90 → Free

### Total
Total = Subtotal − Discount + Delivery Fee


## 💡 Key Assumptions

1. **Session-based Basket** – Each visitor has one active basket tied to their session.
2. **Money Precision** – All amounts stored in integer cents to prevent rounding issues.
3. **Post-Discount Delivery** – Delivery tiers are calculated *after* discounts are applied.
4. **Offer Handling** – Offers defined with flexible JSON metadata, making new offer types easy to add.
5. **Inactive or Invalid Offers** – Skipped gracefully without exceptions.
6. **Zero Quantity** – Removes the product line from the basket.
7. **Empty Basket** – Subtotal, discount, and delivery all return `$0.00`.
8. **Discount Bounds** – Discount never exceeds subtotal.
9. **Full Discount Case** – If subtotal = 0 after discount, delivery resets to base $4.95.
10. **Performance** – All associations preloaded to avoid N+1 queries.
11. **Frontend Interaction** – Stimulus.js updates totals live; no full page reload.


## 🧪 Test Coverage

All 52 tests pass successfully.

Run tests with:
`rails test`

### Covered Areas

| Category | Description |
|-----------|-------------|
| Models | Product, Offer, DeliveryRule, Basket, BasketItem |
| Service | Pricing::Engine handles all pricing logic |
| Controllers | ApplicationController, BasketsController, ProductsController |
| Integration | Verifies all expected totals and live recalculation behavior |

### Verified Totals

| Basket | Total |
|---------|--------|
| B01, G01 | $37.85 |
| R01, R01 | $54.37 |
| R01, G01 | $60.85 |
| B01, B01, R01, R01, R01 | $98.27 |

### Edge Cases
- Empty basket (`$0.00`)
- Invalid meta data
- Inactive offers
- Quantity = 0
- Full discount with base delivery


## 🧰 Design Choices

- **Service-Oriented Architecture** – `Pricing::Engine` cleanly separates business logic.
- **Atomic Operations** – Basket updates use database transactions.
- **Money in Cents** – Ensures financial precision.
- **Real-Time UI** – Stimulus controllers keep the experience seamless.
- **Performance Optimized** – Uses includes and caching for faster basket recalculation.


## 🔮 Future Enhancements

- Support for percentage-based and fixed discounts
- Promo codes and coupons
- Multi-currency support
- Admin dashboard for managing offers and products
- Turbo Streams for real-time checkout experience
- Persistent baskets via cookies or user accounts


## 🏁 Conclusion

The **Acme Shop** project demonstrates:
- Real-world Rails architecture
- Separation of concerns through service objects
- Full test coverage for business rules
- Modern, responsive UI with instant updates
- Clean, extensible foundation for e-commerce logic

It’s not just a challenge solution — it’s a production-ready example of well-structured full-stack engineering.

---

## 👨‍💻 Author

**Uzair Nadeem**
Full-Stack Ruby on Rails Developer

🌐 [LinkedIn](https://www.linkedin.com/in/uznadeem/)
📧 uzairnadeem.se@gmail.com

---

## 📜 License

This project is created for educational and evaluation purposes based on the
**Piktochart Fullstack Developer Coding Test** specification.
