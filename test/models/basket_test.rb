require "test_helper"

class BasketTest < ActiveSupport::TestCase
  fixtures :products, :delivery_rules, :offers, :baskets, :basket_items

  def cents(x) = (x.to_f * 100).round

  test "subtotal uses pricing_payload and sums correctly" do
    b = baskets(:bg)
    payload = b.pricing_payload
    assert_equal 3290, cents(payload[:subtotal])
  end

  test "discount for R01 bogo_half (pairs only)" do
    b = baskets(:rr)
    payload = b.pricing_payload
    assert_equal 1648, cents(payload[:discount])
  end

  test "delivery fee is based on post-discount subtotal" do
    b = baskets(:rr)
    payload = b.pricing_payload
    assert_equal 495, cents(payload[:delivery])
  end

  test "total for B01,G01 is $37.85" do
    b = baskets(:bg)
    assert_equal 3785, cents(b.pricing_payload[:total])
  end

  test "total for R01,R01 is $54.37" do
    b = baskets(:rr)
    assert_equal 5437, cents(b.pricing_payload[:total])
  end

  test "total for R01,G01 is $60.85" do
    b = baskets(:rg)
    assert_equal 6085, cents(b.pricing_payload[:total])
  end

  test "total for B01,B01,R01,R01,R01 is $98.27" do
    b = baskets(:combo)
    assert_equal 9827, cents(b.pricing_payload[:total])
  end

  test "add_product increments quantity instead of duplicating row" do
    b = Basket.create!
    r01 = products(:r01)
    2.times { b.add_product(r01.id) }
    assert_equal 1, b.basket_items.where(product_id: r01.id).count
    assert_equal 2, b.basket_items.find_by(product_id: r01.id).quantity
  end

  test "empty basket has zero subtotal and base delivery fee" do
    b = Basket.create!
    payload = b.pricing_payload
    to_cents = ->(d) { (d.to_f * 100).round }
    assert_equal 0, to_cents.call(payload[:subtotal])
    assert_equal 0, to_cents.call(payload[:discount])
    assert_equal 0, to_cents.call(payload[:delivery])
    assert_equal 0, to_cents.call(payload[:total])
  end

  test "bogo_half discount only applies per pair (odd quantity)" do
    r01 = products(:r01)
    b = Basket.create!
    3.times { b.add_product(r01.id) }
    expected_discount = (r01.price.cents / 2.0).round
    assert_equal expected_discount, cents(b.pricing_payload[:discount])
  end

  test "bogo_half uses HALF_UP rounding correctly" do
    r01 = products(:r01)
    b = Basket.create!
    2.times { b.add_product(r01.id) }
    assert_equal 1648, cents(b.pricing_payload[:discount])
  end

  test "delivery_fee correctly transitions between tiers" do
    # < $50 → 4.95
    b = Basket.create!
    b.add_product(products(:b01).id)
    b.add_product(products(:g01).id)
    assert_equal 495, cents(b.pricing_payload[:delivery])

    # $50–$90 → 2.95
    b = Basket.create!
    b.add_product(products(:r01).id)
    b.add_product(products(:g01).id)
    assert_equal 295, cents(b.pricing_payload[:delivery])

    # ≥ $90 → 0
    b = Basket.create!
    b.add_product(products(:b01).id)
    b.add_product(products(:b01).id)
    3.times { b.add_product(products(:r01).id) }
    assert_equal 0, cents(b.pricing_payload[:delivery])
  end

  test "pricing_payload delegates to service.as_json" do
    b = Basket.create!
    fake_engine = Minitest::Mock.new
    fake_engine.expect(:as_json, { subtotal: 0.0, discount: 0.0, delivery: 0.0, total: 0.0, lines: {} })
    Pricing::Engine.stub(:new, ->(arg) { assert_same b, arg; fake_engine }) do
      payload = b.pricing_payload
      assert_equal 0.0, payload[:subtotal]
      assert_equal 0.0, payload[:discount]
      assert_equal 0.0, payload[:delivery]
      assert_equal 0.0, payload[:total]
      assert_equal({}, payload[:lines])
    end
    assert_mock fake_engine
  end

  test "apply_quantities! creates, updates and destroys items" do
    b = Basket.create!
    r01 = products(:r01)
    g01 = products(:g01)
    b01 = products(:b01)

    b.apply_quantities!({ r01.id => 2, g01.id => 1 })
    assert_equal 2, b.basket_items.find_by(product_id: r01.id).quantity
    assert_equal 1, b.basket_items.find_by(product_id: g01.id).quantity

    b.apply_quantities!({ r01.id => 3 })
    assert_equal 3, b.basket_items.find_by(product_id: r01.id).quantity

    b.apply_quantities!({ g01.id => 0 })
    assert_nil b.basket_items.find_by(product_id: g01.id)

    b.apply_quantities!({ b01.id => 4 })
    assert_equal 4, b.basket_items.find_by(product_id: b01.id).quantity
  end

  test "pricing_payload includes line totals keyed by product_id" do
    b = Basket.create!
    r01 = products(:r01)
    g01 = products(:g01)
    b.apply_quantities!({ r01.id => 2, g01.id => 1 })
    lines = b.pricing_payload[:lines]
    assert_equal r01.price.cents * 2, lines[r01.id.to_s]
    assert_equal g01.price.cents * 1, lines[g01.id.to_s]
  end
end
