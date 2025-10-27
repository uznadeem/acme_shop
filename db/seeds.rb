Product.upsert_all([
  { code: "R01", name: "Red Widget",   price_cents: (32.95 * 100).round, updated_at: Time.current, created_at: Time.current },
  { code: "G01", name: "Green Widget", price_cents: (24.95 * 100).round, updated_at: Time.current, created_at: Time.current },
  { code: "B01", name: "Blue Widget",  price_cents: (7.95  * 100).round, updated_at: Time.current, created_at: Time.current }
], unique_by: :index_products_on_code)

DeliveryRule.delete_all
DeliveryRule.create!(threshold_cents:    0, fee_cents: (4.95 * 100).round)
DeliveryRule.create!(threshold_cents: 5000, fee_cents: (2.95 * 100).round)
DeliveryRule.create!(threshold_cents: 9000, fee_cents: 0)

Offer.where(kind: "bogo_half").delete_all
Offer.create!(kind: "bogo_half", product: Product.find_by!(code: "R01"), meta: { "pair_discount" => 0.5 }, active: true)
