class CreateRelPairComps < ActiveRecord::Migration[6.1]
  def change
    create_table :rel_pair_comps do |t|
      t.integer :pair_id
      t.integer :comp_id
      t.float :score

      t.timestamps
    end
  end
end
