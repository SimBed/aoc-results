class AddConventionsToPairs < ActiveRecord::Migration[6.1]
  def change
    add_column :pairs, :notrump, :string
    add_column :pairs, :system, :string
  end
end
