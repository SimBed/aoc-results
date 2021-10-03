class AddPairCountToComps < ActiveRecord::Migration[6.1]
  def change
    add_column :comps, :pair_count, :integer
  end
end
