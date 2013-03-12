class CreateScoresTable < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :computer, :default => 0
      t.integer :player, :default => 0
      t.integer :game_id
      t.timestamps
    end
  end
end
