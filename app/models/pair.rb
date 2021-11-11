class Pair < ApplicationRecord
  has_many :rel_pair_comps, dependent: :destroy
  has_many :comps, through: :rel_pair_comps
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  validates :player1_id, uniqueness: {scope: :player2_id}
  validates :player2_id, uniqueness: {scope: :player1_id}
  validate :pair_combination_must_be_unique

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
    ((pos_pct_accum / rel_pair_comps.count) * field).round(1)
  end

  def name
    "#{Player.find(self.player1_id).full_name} & #{Player.find(self.player2_id).full_name}"
  end

  def played
    rel_pair_comps.count
  end

  def first_played
    return 'na' if comps.nil?
    comps.sort_by { |c| c.date}.first
  end

  def last_played
    return 'na' if comps.nil?
    comps.sort_by { |c| c.date}.last
  end

  def max_score(rels)
    rel = rels.sort_by { |r| r.score }.last
    { score: rel.score, comp: Comp.find(rel.comp_id) }
  end

  def min_score(rels)
    rel = rels.sort_by { |r| r.score }.first
    { score: rel.score, comp: Comp.find(rel.comp_id) }
  end

  def max_pos(rels, max: true, standardise: true, field: 20)
    return 'na' if rels.count.zero?
    if standardise
      rels = rels.sort_by { |r| r.position_pct }
      ((max ? rels.first.position_pct : rels.last.position_pct) * field).round(1)
    else
      rels = rels.sort_by { |r| r.pos }
      (max ? rels.first.pos : rels.last.pos)
    end
  end

  private

  # reformat to use exists?
  def pair_combination_must_be_unique
    errors.add(:player1_id, "pair already created") unless
      Pair.find_by(player1_id: player1_id, player2_id: player2_id).nil? &&
      Pair.find_by(player1_id: player2_id, player2_id: player1_id).nil?
  end
end
