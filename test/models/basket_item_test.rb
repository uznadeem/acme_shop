require "test_helper"

class BasketItemTest < ActiveSupport::TestCase
  fixtures :baskets, :products, :basket_items

  test "valid fixtures" do
    assert basket_items(:bg_b01).valid?
    assert basket_items(:bg_g01).valid?
  end

  test "quantity must be > 0" do
    bi = BasketItem.new(basket: baskets(:empty), product: products(:r01), quantity: 0)
    assert_not bi.valid?
    assert_includes bi.errors[:quantity], "must be greater than 0"
  end

  test "uniqueness of product per basket" do
    bi = BasketItem.new(basket: baskets(:bg), product: products(:b01), quantity: 1)
    assert_not bi.valid?
    assert_includes bi.errors[:product_id], "has already been taken"
  end

  test "associations" do
    bi = basket_items(:bg_b01)
    assert_equal baskets(:bg), bi.basket
    assert_equal products(:b01), bi.product
  end

  test "quantity cannot be zero or negative" do
    bi = BasketItem.new(basket: baskets(:empty), product: products(:r01), quantity: 0)
    assert_not bi.valid?
    bi.quantity = -1
    assert_not bi.valid?
  end

  test "add_product increments quantity and does not duplicate rows" do
    b = Basket.create!
    pid = products(:b01).id
    3.times { b.add_product(pid) }
    assert_equal 1, b.basket_items.where(product_id: pid).count
    assert_equal 3, b.basket_items.find_by(product_id: pid).quantity
  end
end
