class Pair < ApplicationRecord
  has_many :rel_pair_comps, dependent: :destroy
  has_many :comps, through: :rel_pair_comps
  belongs_to :player1, class_name: 'Player'
  belongs_to :player2, class_name: 'Player'
  validates :player1_id, uniqueness: {scope: :player2_id}
  validates :player2_id, uniqueness: {scope: :player1_id}
  # https://stackoverflow.com/questions/24279948/rails-validate-only-on-create-or-on-update-when-field-is-not-blank
  validate :pair_combination_must_be_unique, on: :create

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

  def self.order_by_av_score
    # sql = "SELECT pid, AVG(score) avgscore FROM
    #       (SELECT pairs.id pid, rel.score score FROM pairs
    #        INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id) t
    #        GROUP BY pid ORDER BY avgscore DESC;"
    sql = "WITH v3 AS (
             SELECT pairs.id AS pairid, rel.score AS score
             FROM pairs INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                      ),
                V4 as (
             SELECT pairid, avg(score) avgscore,
                    RANK() OVER (ORDER BY avg(score) DESC) AS rank,
                    count(score) played
             FROM v3 GROUP BY pairid
                      ),
                V5 as (
             SELECT pairid, avgscore, rank, played, p.first_name as p1firstname, p.last_name as p1lastname
             FROM v4 INNER JOIN pairs ON v4.pairid = pairs.id
                     INNER JOIN players p ON player1_id = p.id
                      )
           SELECT pairid, avgscore, rank, played,
                  p1firstname, p1lastname, p.first_name as p2firstname, p.last_name as p2lastname
           FROM v5 INNER JOIN pairs on v5.pairid = pairs.id INNER JOIN players p ON player2_id = p.id
            ORDER BY avgscore DESC;"

          #
          #
          #
          # SELECT pairid, avg(score) avgscore,
          #        RANK() OVER (ORDER BY avg(score) DESC) AS rank
          # FROM v3 GROUP BY pairid ORDER BY avgscore DESC;"
    # records_array = ActiveRecord::Base.connection.execute(sql)
    # ordered_pairs_id_array = records_array.values.each {|row| row.delete_at 1}.each {|row| row.delete_at 1}.flatten
    # Pair.find(ordered_pairs_id_array)
    # runs the query, return an ActiveRecord::Result, which to_a turns into an array of hashes with the column names as keys
    ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def self.order_by_name
    sql = "WITH v3 AS (
             SELECT pairs.id AS pairid, rel.score AS score
             FROM pairs INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                      ),
                V4 as (
             SELECT pairid, avg(score) avgscore,
                    RANK() OVER (ORDER BY avg(score) DESC) AS rank,
                    count(score) played
             FROM v3 GROUP BY pairid
                      ),
                V5 as (
             SELECT pairid, avgscore, rank, played, p.first_name as p1firstname, p.last_name as p1lastname
             FROM v4 INNER JOIN pairs ON v4.pairid = pairs.id
                     INNER JOIN players p ON player1_id = p.id
                      )
           SELECT pairid, avgscore, rank, played,
                  p1firstname, p1lastname, p.first_name as p2firstname, p.last_name as p2lastname
           FROM v5 INNER JOIN pairs on v5.pairid = pairs.id INNER JOIN players p ON player2_id = p.id
            ORDER BY p1firstname, p1lastname, p2firstname, p2lastname;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def self.order_by_played
    sql = "WITH v3 AS (
             SELECT pairs.id AS pairid, rel.score AS score
             FROM pairs INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                      ),
                V4 as (
             SELECT pairid, avg(score) avgscore,
                    RANK() OVER (ORDER BY avg(score) DESC) AS rank,
                    count(score) played
             FROM v3 GROUP BY pairid
                      ),
                V5 as (
             SELECT pairid, avgscore, rank, played, p.first_name as p1firstname, p.last_name as p1lastname
             FROM v4 INNER JOIN pairs ON v4.pairid = pairs.id
                     INNER JOIN players p ON player1_id = p.id
                      )
           SELECT pairid, avgscore, rank, played,
                  p1firstname, p1lastname, p.first_name as p2firstname, p.last_name as p2lastname
           FROM v5 INNER JOIN pairs on v5.pairid = pairs.id INNER JOIN players p ON player2_id = p.id
            ORDER BY played;"
    ActiveRecord::Base.connection.exec_query(sql).to_a
  end

  def self.order_by_av_position
    sql = "WITH v1 AS (
              SELECT pairs.id AS pairid, comps.id AS compid, rel.score AS score,
                     RANK() OVER ( PARTITION BY comps.id ORDER BY score DESC) AS rank
              FROM pairs INNER JOIN rel_pair_comps rel ON pairs.id = rel.pair_id
                         INNER JOIN comps ON comps.id = rel.comp_id
              ORDER BY pairs.id
                      )
           SELECT pairid, avg(rank) FROM v1 GROUP BY pairid ORDER BY pairid;"
    records_array = ActiveRecord::Base.connection.execute(sql)
    ordered_pairs_id_array = records_array.values.each {|row| row.delete_at 1}.flatten
    Pair.find(ordered_pairs_id_array)
  end

  private

  # reformat to use exists?
  def pair_combination_must_be_unique
    errors.add(:player1_id, "pair already created") unless
      Pair.find_by(player1_id: player1_id, player2_id: player2_id).nil? &&
      Pair.find_by(player1_id: player2_id, player2_id: player1_id).nil?
  end
end
