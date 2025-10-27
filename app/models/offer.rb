class Offer < ApplicationRecord
  KINDS = %w[bogo_half].freeze

  belongs_to :product, optional: true
  validates :kind, presence: true, inclusion: { in: KINDS }

  validate :meta_values_sane

  private

  def meta_values_sane
    return unless kind == "bogo_half"
    d = meta.is_a?(Hash) ? meta["pair_discount"] : nil
    errors.add(:meta, "pair_discount must be between 0 and 1") if d && !(0.0..1.0).cover?(d.to_f)
  end
end
