class ApplicationController < ActionController::Base
  helper_method :current_basket

  private

  def current_basket
    @current_basket ||= begin
      session[:basket_id] ||= Basket.create!.id
      Basket.find(session[:basket_id])
    end
  end
end
