class RelPairComp < ApplicationRecord
  belongs_to :pair
  belongs_to :comp
  scope :order_by_date_score, -> { order(comp_id: :desc, score: :desc ) }

  def pos
    comp_scores = comp.rel_pair_comps.map {|rel| rel.score}.sort_by(&:-@)
    pair_position = comp_scores.index(score) + 1
    "#{pair_position} #{'=' * (comp_scores.count(score) - 1)}"
  end

  def pos_numeric
    pos.delete("=").to_i
  end

  def position_pct
    return 0 if Comp.find(comp_id).pairs.count.zero?
    pos_numeric.to_f / Comp.find(comp_id).pairs.count
  end
end
