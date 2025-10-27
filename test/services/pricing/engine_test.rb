require "test_helper"

class PricingEngineTest < ActiveSupport::TestCase
  fixtures :products, :delivery_rules, :offers

  def build_basket(*codes)
    b = Basket.create!
    codes.each { |c| b.add_product(Product.find_by!(code: c).id) }
    b
  end

  test "subtotal cents" do
    b = build_basket("R01", "G01") # 32.95  24.95 = 57.90
    assert_equal 5790, Pricing::Engine.new(b).send(:subtotal_cents)
  end

  test "discount cents for pair of R01" do
    b = build_basket("R01", "R01") # one half R01 => 1648
    assert_equal 1648, Pricing::Engine.new(b).send(:discount_cents)
  end

  test "discount only per floor(quantity/2)" do
    b = build_basket("R01", "R01", "R01")
    assert_equal 1648, Pricing::Engine.new(b).send(:discount_cents)
  end

  test "delivery cents across tiers" do
    assert_equal 495, Pricing::Engine.new(build_basket("B01", "G01")).send(:delivery_cents)               # < $50
    assert_equal 295, Pricing::Engine.new(build_basket("R01", "G01")).send(:delivery_cents)               # $50–$89.99
    assert_equal 0,   Pricing::Engine.new(build_basket("B01", "B01", "R01", "R01", "R01")).send(:delivery_cents) # ≥ $90
  end

  test "totals match challenge examples" do
    {
      %w[B01 G01]                     => 3785,
      %w[R01 R01]                     => 5437,
      %w[R01 G01]                     => 6085,
      %w[B01 B01 R01 R01 R01]         => 9827
    }.each do |codes, expected|
      b = build_basket(*codes)
      assert_equal expected, Pricing::Engine.new(b).total.cents, "Mismatch for #{codes.join(', ')}"
    end
  end

  test "as_json returns full payload including lines" do
    b = build_basket("R01", "G01")
    payload = Pricing::Engine.new(b).as_json
    assert_includes payload.keys, :subtotal
    assert_includes payload.keys, :discount
    assert_includes payload.keys, :delivery
    assert_includes payload.keys, :total
    assert_includes payload.keys, :lines
    # quick sanity on lines
    assert payload[:lines].is_a?(Hash)
    # values are cents
    payload[:lines].each_value { |v| assert v.is_a?(Integer) }
  end

  test "line totals are correct per product id" do
    b = Basket.create!
    r01 = products(:r01); g01 = products(:g01)
    b.apply_quantities!({ r01.id => 2, g01.id => 3 })
    payload = Pricing::Engine.new(b).as_json
    assert_equal r01.price.cents * 2, payload[:lines][r01.id.to_s]
    assert_equal g01.price.cents * 3, payload[:lines][g01.id.to_s]
  end
end
