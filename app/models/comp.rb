class Comp < ApplicationRecord
  has_many :rel_pair_comps, dependent: :destroy
  has_many :pairs, through: :rel_pair_comps
  has_many :players, through: :pairs
  validates :date, uniqueness: true
  scope :order_by_date, -> { order(date: :desc) }

  def formatted_date
    date.strftime('%a %d %b %y')
  end
end
