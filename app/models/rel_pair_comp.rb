class RelPairComp < ApplicationRecord
  belongs_to :pair
  belongs_to :comp
  scope :order_by_date_score, -> { order(comp_id: :desc, score: :desc ) }

  def position_pct
    return 0 if Comp.find(comp_id).nil? || Comp.find(comp_id).zero?
    position.to_f / Comp.find(comp_id).pair_count
  end
end
