class BasketItem < ApplicationRecord
  belongs_to :basket
  belongs_to :product

  validates :product_id, uniqueness: { scope: :basket_id }
  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
