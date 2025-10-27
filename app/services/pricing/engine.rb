module Pricing
  class Engine
    def initialize(basket)
      @basket = basket
    end

    def as_json
      {
        subtotal: subtotal.to_f,
        discount: discount.to_f,
        delivery: delivery.to_f,
        total:    total.to_f,
        lines:    line_totals_cents
      }
    end

    def subtotal   = Money.new(subtotal_cents, "USD")
    def discount   = Money.new(discount_cents, "USD")
    def delivery   = Money.new(delivery_cents, "USD")
    def total      = Money.new(total_cents, "USD")

    private

    attr_reader :basket

    def items
      @items ||= basket.basket_items.includes(:product)
    end

    def subtotal_cents
      items.sum { |bi| bi.quantity * bi.product.price_cents }
    end

    def discount_cents
      offers_by_product = active_offers_by_product_id
      return 0 if offers_by_product.empty?

      items.sum do |bi|
        offer = offers_by_product[bi.product_id]
        next 0 unless offer

        case offer.kind
        when "bogo_half"
          raw = offer.meta.is_a?(Hash) ? offer.meta["pair_discount"] : nil
          pair_discount = [ [ raw.to_f, 0.0 ].max, 1.0 ].min
          pairs = bi.quantity / 2
          (bi.product.price_cents * pairs * pair_discount).round
        else
          0
        end
      end
    end

    def delivery_cents
      after_discount = subtotal_cents - discount_cents
      DeliveryRule.fee_for(after_discount)
    end

    def total_cents
      subtotal_cents - discount_cents + delivery_cents
    end

    def line_totals_cents
      items.map { |bi| [ bi.product_id.to_s, bi.product.price_cents * bi.quantity ] }.to_h
    end

    def active_offers_by_product_id
      product_ids = items.map(&:product_id).uniq
      Offer.where(active: true, product_id: product_ids, kind: "bogo_half").index_by(&:product_id)
    end
  end
end
