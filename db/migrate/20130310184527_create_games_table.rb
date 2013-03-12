class CreateGamesTable < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :final_computer_score
      t.integer :final_player_score
      t.integer :winner
      t.integer :user_id
      t.timestamps
    end
  end
end
