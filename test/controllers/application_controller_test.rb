require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  fixtures :products, :delivery_rules, :offers

  test "current_basket creates a basket when session is empty" do
    assert_difference -> { Basket.count }, 1 do
      get root_path
      assert_response :success
    end
  end

  test "current_basket reuses the same basket across requests" do
    get root_path
    assert_response :success
    assert_no_difference -> { Basket.count } do
      get root_path
      assert_response :success
    end
  end
end
