class Product < ApplicationRecord
  has_many :basket_items
  has_many :baskets, through: :basket_items

  validates :code, :name, presence: true
  validates :code, uniqueness: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }

  def price
    Money.new(price_cents, "USD")
  end

  def price=(value)
    amount = case value

    when Money   then value
    when String  then Money.from_amount(BigDecimal(value), "USD")
    when Numeric then Money.from_amount(BigDecimal(value.to_s), "USD")
    else
      raise ArgumentError, "Unsupported price value: #{value.inspect}"
    end

    self.price_cents = amount.cents
  end
end
