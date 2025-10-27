require "test_helper"

class OfferTest < ActiveSupport::TestCase
  fixtures :offers, :products
  def cents(x) = (x.to_f * 100).round


  test "valid bogo_half offer" do
    offer = offers(:bogo_half_r01)
    assert offer.valid?
    assert_equal "bogo_half", offer.kind
    assert offer.active
    assert_equal products(:r01).id, offer.product_id
    assert_equal 0.5, offer.meta["pair_discount"]
  end

  test "product optional for future site-wide offers" do
    offer = Offer.new(kind: "bogo_half", meta: { "pair_discount" => 0.5 }, active: true)
    assert offer.valid?, "Offer should be valid without product for future flexibility"
  end

  test "kind presence" do
    o = Offer.new(meta: {})
    assert_not o.valid?
    assert_includes o.errors[:kind], "can't be blank"
  end

  test "inactive offer is ignored by basket discount logic" do
    o = offers(:bogo_half_r01)
    o.update!(active: false)
    b = Basket.create!
    2.times { b.add_product(products(:r01).id) }
    assert_equal 0, cents(b.pricing_payload[:discount])
  end

  test "offer with invalid meta shape does not crash" do
    o = offers(:bogo_half_r01)
    o.update!(meta: "invalid")
    b = Basket.create!
    2.times { b.add_product(products(:r01).id) }
    assert_equal 0, cents(b.pricing_payload[:discount])
  end
end
