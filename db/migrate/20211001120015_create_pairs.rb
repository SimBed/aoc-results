class CreatePairs < ActiveRecord::Migration[6.1]
  def change
    create_table :pairs do |t|
      t.integer :player1_id
      t.integer :player2_id

      t.timestamps
    end
  end
end
