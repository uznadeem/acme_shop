require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  fixtures :products, :delivery_rules, :offers

  test "GET / (products#index) renders the products table and creates a basket" do
    get root_path
    assert_response :success

    # a basket should be created in the session by ApplicationController#current_basket
    assert @request.session[:basket_id].present?

    # table and rows present
    assert_select "table#products-table"
    assert_select "table#products-table tbody tr", Product.count

    # a couple of spot checks for product codes rendered
    assert_includes @response.body, products(:b01).code
    assert_includes @response.body, products(:g01).code
    assert_includes @response.body, products(:r01).code
  end
end
