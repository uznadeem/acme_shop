require "test_helper"

class BasketsControllerTest < ActionDispatch::IntegrationTest
  fixtures :products, :delivery_rules, :offers

  def json_response
    JSON.parse(@response.body)
  end

  test "POST /basket/calculate persists quantities and returns pricing payload" do
    r01 = products(:r01) # 3295
    g01 = products(:g01) # 2495

    # seed a basket via products#index to initialize session
    get root_path
    basket_id = @request.session[:basket_id]
    assert basket_id

    post calculate_basket_path, params: { quantities: { r01.id => 2, g01.id => 1 } }
    assert_response :success

    payload = json_response.symbolize_keys
    %i[subtotal discount delivery total lines].each { |k| assert payload.key?(k) }

    # lines should be cents hash keyed by product_id
    assert_equal r01.price.cents * 2, payload[:lines][r01.id.to_s]
    assert_equal g01.price.cents * 1, payload[:lines][g01.id.to_s]

    # quick cents-level checks for the classic rules:
    # subtotal = 2*3295 + 2495 = 9085
    # discount = half of 3295 for the R01 pair = 1648
    # after    = 9085 - 1648 = 7437 => delivery tier 295
    # total    = 7437 + 295 = 7732
    to_cents = ->(dollars_float) { (dollars_float.to_f * 100).round }
    assert_equal 9085, to_cents.call(payload[:subtotal])
    assert_equal 1648, to_cents.call(payload[:discount])
    assert_equal 295, to_cents.call(payload[:delivery])
    assert_equal 7732, to_cents.call(payload[:total])

    # and the DB really persisted the quantities
    b = Basket.find(basket_id)
    assert_equal 2, b.basket_items.find_by(product_id: r01.id).quantity
    assert_equal 1, b.basket_items.find_by(product_id: g01.id).quantity
  end

  test "setting a product quantity to 0 removes the row" do
    r01 = products(:r01)

    get root_path
    post calculate_basket_path, params: { quantities: { r01.id => 3 } }
    assert_response :success
    b = Basket.find(@request.session[:basket_id])
    assert_equal 1, b.basket_items.where(product_id: r01.id).count

    # now zero it out
    post calculate_basket_path, params: { quantities: { r01.id => 0 } }
    assert_response :success
    b.reload
    assert_nil b.basket_items.find_by(product_id: r01.id)
  end

  test "POST /basket/calculate without quantities still returns a payload" do
    get root_path
    post calculate_basket_path
    assert_response :success

    payload = json_response.symbolize_keys
    %i[subtotal discount delivery total lines].each { |k| assert payload.key?(k) }
    # empty basket => subtotal 0, delivery 0, total 0
    to_cents = ->(d) { (d.to_f * 100).round }
    assert_equal 0,    to_cents.call(payload[:subtotal])
    assert_equal 0,    to_cents.call(payload[:discount])
    assert_equal 0,  to_cents.call(payload[:delivery])
    assert_equal 0,  to_cents.call(payload[:total])
    assert_equal({},   payload[:lines])
  end
end
