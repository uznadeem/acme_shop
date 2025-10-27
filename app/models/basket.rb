class Basket < ApplicationRecord
  has_many :basket_items, dependent: :destroy
  has_many :products, through: :basket_items

  def add_product(product_id)
    item = basket_items.find_by(product_id: product_id)
    item ? item.increment!(:quantity) : basket_items.create!(product_id: product_id, quantity: 1)
  end

  def apply_quantities!(quantities)
    transaction do
      (quantities || {}).each do |pid, q|
        item = basket_items.find_or_initialize_by(product_id: pid)
        q.to_i.positive? ? item.update!(quantity: q) : item.destroy!
      end
    end
    self
  end

  def pricing_payload
    Pricing::Engine.new(self).as_json
  end
end
