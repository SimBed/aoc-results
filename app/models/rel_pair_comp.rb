class RelPairComp < ApplicationRecord
  belongs_to :pair
  belongs_to :comp
  scope :order_by_date_score, -> { order(comp_id: :desc, score: :desc ) }
end
