class ApplicationController < ActionController::Base
  helper_method :current_basket

  private

  def current_basket
    @current_basket ||= begin
      id      = session[:basket_id]
      basket  = id && Basket.find_by(id: id)

      unless basket
        basket = Basket.create!
        session[:basket_id] = basket.id
      end

      basket
    end
  end
end
