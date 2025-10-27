class ProductsController < ApplicationController
  def index
    @products = Product.order(:code)
    @basket   = current_basket
  end
end
