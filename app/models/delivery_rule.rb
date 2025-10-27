class DeliveryRule < ApplicationRecord
  validates :threshold_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :fee_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :threshold_cents, uniqueness: true

  scope :by_threshold, -> { order(threshold_cents: :asc) }

  def self.fee_for(subtotal_cents)
    where("threshold_cents <= ?", subtotal_cents)
      .order(threshold_cents: :desc)
      .limit(1)
      .pick(:fee_cents) || 0
  end
end
