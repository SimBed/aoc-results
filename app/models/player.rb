class Player < ApplicationRecord
  has_many :pairs_as_player1s, class_name: 'Pair', foreign_key: :player1_id, dependent: :destroy
  has_many :pairs_as_player2s, class_name: 'Pair', foreign_key: :player2_id, dependent: :destroy
  validates :first_name, uniqueness: {scope: :last_name}
  # has_many :rel_pair1_comps, class_name: 'RelPairComp', foreign_key: :pair_id, through: :pairs_as_player1s
  # has_many :rel_pair2_comps, through: :pairs_as_player1s
  # has_many :comps, through: :rel_pair_comps
  scope :order_by_first_name, -> { order(first_name: :asc) }

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
    # score = 0
    # rel_pair_comps.each do |rel|
    #   score += rel.score
    # end
    rpc = rel_pair_comps
    return 0 if rpc.count.zero?
    # sum is a rails implementation for arrays
    score = rpc.map(&:score).sum
    (score / rpc.count).round(2)
  end

  def average_position(field = 20)
    # pos_pct_accum = 0
    # rel_pair_comps.each do |rel|
    #   pos_pct_accum += rel.position_pct
    # end
    # return pos_pct_accum if rel_pair_comps.size.zero?
    # ((pos_pct_accum / rel_pair_comps.size) * field).round(1)
    rpc = rel_pair_comps
    return 0 if rpc.size.zero?
    pos_pct_accum = rpc.map(&:position_pct).sum
    ((pos_pct_accum / rpc.size) * field).round(1)
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
    rels = rels.sort_by { |r| r.position_pct }
    if standardise
      ((max ? rels.first.position_pct : rels.last.position_pct) * field).round(1)
    else
      (max ? [rels.first.pos, rels.first.comp.rel_pair_comps.count] : [rels.last.pos, rels.last.comp.rel_pair_comps.count])
    end
  end

# refactor these repeated methods (with variable) in due course
  def a_s(rels)
    score = 0
    rels.each do |rel|
      score += rel.score
    end
    return score if rels.count.zero?
    (score / rels.count).round(2)
  end

# refactor in due course
  def a_p(rels, field = 20)
    pos_pct_accum = 0
    rels.each do |rel|
      pos_pct_accum += rel.position_pct
    end
    return pos_pct_accum if rels.count.zero?
    ((pos_pct_accum / rels.count) * field).round(1)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def played
    rel_pair_comps.count
  end

  def partner_name(pair)
    pair_names = pair.name.split('&').map { |player| player.strip }
    pair_names[0] == self.full_name ? pair_names[1] : pair_names[0]
  end

def first_played
  return 'na' if comps.nil?
  comps.sort_by { |c| c.date}.first
end

def last_played
  return 'na' if comps.nil?
  comps.sort_by { |c| c.date}.last
end

#not used - this runs too slowly to perform the sort for each player. The sort is done once in the controller instead and the index in the view
def rank
  Player.all.sort_by { |p| -p.average_score }.index(self) + 1
end

def self.order_by_av_score
  sql = "WITH v1 AS (
               SELECT p.id pid, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player1_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
               UNION
               SELECT p.id, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player2_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                	  ),
              v2 AS (
                 SELECT pid, AVG(score) AS avgscore, COUNT(score) played
                 FROM v1 GROUP BY pid ORDER BY avgscore DESC
                    ),
              v3 AS (
                SELECT pid, avgscore, played,
                RANK() OVER (ORDER BY avgscore DESC) AS rank
                FROM v2
              	   )
              SELECT pid, avgscore, played, rank, p.first_name AS firstname, p.last_name AS lastname
              FROM v3 INNER JOIN players p ON p.id = v3.pid
              ORDER BY avgscore DESC;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
end

def self.order_by_firstname
  sql = "WITH v1 AS (
               SELECT p.id pid, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player1_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
               UNION
               SELECT p.id, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player2_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                	  ),
              v2 AS (
                 SELECT pid, AVG(score) AS avgscore, COUNT(score) played
                 FROM v1 GROUP BY pid ORDER BY avgscore DESC
                    ),
              v3 AS (
                SELECT pid, avgscore, played,
                RANK() OVER (ORDER BY avgscore DESC) AS rank
                FROM v2
              	   )
              SELECT pid, avgscore, played, rank, p.first_name AS firstname, p.last_name AS lastname
              FROM v3 INNER JOIN players p ON p.id = v3.pid
              ORDER BY firstname;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
end

def self.order_by_lastname
  sql = "WITH v1 AS (
               SELECT p.id pid, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player1_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
               UNION
               SELECT p.id, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player2_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                	  ),
              v2 AS (
                 SELECT pid, AVG(score) AS avgscore, COUNT(score) played
                 FROM v1 GROUP BY pid ORDER BY avgscore DESC
                    ),
              v3 AS (
                SELECT pid, avgscore, played,
                RANK() OVER (ORDER BY avgscore DESC) AS rank
                FROM v2
              	   )
              SELECT pid, avgscore, played, rank, p.first_name AS firstname, p.last_name AS lastname
              FROM v3 INNER JOIN players p ON p.id = v3.pid
              ORDER BY firstname;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
end

def self.order_by_played
  sql = "WITH v1 AS (
               SELECT p.id pid, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player1_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
               UNION
               SELECT p.id, rel.score score FROM players p
                 INNER JOIN pairs ON p.id = pairs.player2_id
                 INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                	  ),
              v2 AS (
                 SELECT pid, AVG(score) AS avgscore, COUNT(score) played
                 FROM v1 GROUP BY pid ORDER BY avgscore DESC
                    ),
              v3 AS (
                SELECT pid, avgscore, played,
                RANK() OVER (ORDER BY avgscore DESC) AS rank
                FROM v2
              	   )
              SELECT pid, avgscore, played, rank, p.first_name AS firstname, p.last_name AS lastname
              FROM v3 INNER JOIN players p ON p.id = v3.pid
              ORDER BY played;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
end

#deprecated
def self.order_by_av_position
  sql = "WITH v2 AS (
            SELECT p.id AS playerid, comps.id AS compid, rel.score AS score,
                   rank() OVER ( PARTITION BY comps.id ORDER BY score DESC) AS rank
            FROM players p INNER JOIN pairs ON p.id = pairs.player1_id
                           INNER JOIN rel_pair_comps rel on pairs.id = rel.pair_id
                           INNER JOIN comps ON rel.comp_id = comps.id
            UNION
            SELECT p.id AS playerid, comps.id AS compid, rel.score AS score,
                   RANK() OVER ( PARTITION BY comps.id ORDER BY score DESC) AS rank
            FROM players p INNER JOIN pairs ON p.id = pairs.player2_id
                           INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                           INNER JOIN comps ON rel.comp_id =comps.id
                    )
        SELECT playerid, AVG(rank) FROM v2 GROUP BY playerid ORDER BY AVG(rank);"
  records_array = ActiveRecord::Base.connection.execute(sql)
  ordered_players_id_array = records_array.values.each {|row| row.delete_at 1}.flatten
  # use find with an array to return an array of objects
  Player.find(ordered_players_id_array)
end

end
