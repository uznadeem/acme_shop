require "test_helper"

class DeliveryRuleTest < ActiveSupport::TestCase
  fixtures :delivery_rules

  test "valid fixtures" do
    assert delivery_rules(:tier_0).valid?
    assert delivery_rules(:tier_50).valid?
    assert delivery_rules(:tier_90).valid?
  end

  test "threshold uniqueness" do
    dup = delivery_rules(:tier_50).dup
    assert_not dup.valid?
    assert_includes dup.errors[:threshold_cents], "has already been taken"
  end

  test "fee_for selects greatest threshold <= subtotal" do
    # < $50
    assert_equal 495, DeliveryRule.fee_for(0)
    assert_equal 495, DeliveryRule.fee_for(4999)

    # ≥ $50 and < $90
    assert_equal 295, DeliveryRule.fee_for(5000)
    assert_equal 295, DeliveryRule.fee_for(8999)

    # ≥ $90
    assert_equal 0, DeliveryRule.fee_for(9000)
    assert_equal 0, DeliveryRule.fee_for(15000)
  end

  test "non-negative constraints" do
    dr = DeliveryRule.new(threshold_cents: -1, fee_cents: 0)
    assert_not dr.valid?
    assert_includes dr.errors[:threshold_cents], "must be greater than or equal to 0"

    dr = DeliveryRule.new(threshold_cents: 100, fee_cents: -5)
    assert_not dr.valid?
    assert_includes dr.errors[:fee_cents], "must be greater than or equal to 0"
  end

  test "fee_for returns default fee for subtotal below first threshold" do
    assert_equal 495, DeliveryRule.fee_for(1) # below $50
  end

  test "fee_for returns lowest fee for highest threshold" do
    assert_equal 0, DeliveryRule.fee_for(10000) # ≥ $90
  end

  test "fee_for handles missing rules gracefully" do
    DeliveryRule.delete_all
    assert_equal 0, DeliveryRule.fee_for(1000)
  end
end
