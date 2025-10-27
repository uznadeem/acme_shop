require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products

  test "valid factory fixtures" do
    assert products(:r01).valid?
    assert products(:g01).valid?
    assert products(:b01).valid?
  end

  test "code uniqueness" do
    dup = products(:r01).dup
    dup.name = "Another Red"
    assert_not dup.valid?
    assert_includes dup.errors[:code], "has already been taken"
  end

  test "price returns Money" do
    p = products(:r01)
    assert_equal 3295, p.price.cents
    assert_equal "USD", p.price.currency.iso_code
  end

  test "price= supports Money/String/Numeric" do
    p = products(:b01)

    p.price = Money.new(1234, "USD")
    assert_equal 1234, p.price_cents

    p.price = "19.99"
    assert_equal 1999, p.price_cents

    p.price = 7.5
    assert_equal 750, p.price_cents
  end

  test "price_cents non-negative" do
    p = Product.new(code: "X01", name: "X", price_cents: -1)
    assert_not p.valid?
    assert_includes p.errors[:price_cents], "must be greater than or equal to 0"
  end

  test "price= supports Money, String, Numeric, and rejects unsupported types" do
    p = products(:b01)

    money = Money.new(1234, "USD")
    p.price = money
    assert_equal 1234, p.price_cents

    p.price = "19.99"
    assert_equal 1999, p.price_cents

    p.price = 7.5
    assert_equal 750, p.price_cents

    assert_raises(ArgumentError) { p.price = [ 1, 2, 3 ] }
  end
end
