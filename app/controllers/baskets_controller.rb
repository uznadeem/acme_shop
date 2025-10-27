class BasketsController < ApplicationController
  def calculate
    basket = current_basket
    basket.apply_quantities!(params[:quantities].to_unsafe_h) if params[:quantities]
    render json: basket.pricing_payload
  end
end
