class Player < ApplicationRecord
  has_many :pairs_as_player1s, class_name: 'Pair', foreign_key: :player1_id, dependent: :destroy
  has_many :pairs_as_player2s, class_name: 'Pair', foreign_key: :player2_id, dependent: :destroy
  validates :first_name, uniqueness: {scope: :last_name}
  # has_many :rel_pair1_comps, class_name: 'RelPairComp', foreign_key: :pair_id, through: :pairs_as_player1s
  # has_many :rel_pair2_comps, through: :pairs_as_player1s
  # has_many :comps, through: :rel_pair_comps
  scope :order_by_created, -> { order(created_at: :desc) }

  def pairs
    Pair.where("player1_id = ? OR player2_id = ?", self.id, self.id).to_a
  end

  def rel_pair_comps
    pairs.map(&:rel_pair_comps).flatten
  end

  def comps
    rel_pair_comps.map(&:comp)
  end

  def average_score
    score = 0
    rel_pair_comps.each do |rel|
      score += rel.score
    end
    return score if rel_pair_comps.count.zero?
    (score / rel_pair_comps.count).round(2)
  end

  def average_position(field = 20)
    pos_pct_accum = 0
    rel_pair_comps.each do |rel|
      pos_pct_accum += rel.position_pct
    end
    return pos_pct_accum if rel_pair_comps.count.zero?
    ((pos_pct_accum / rel_pair_comps.count) * field).round(2)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end
end
