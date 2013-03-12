class CreateActorsGamesTable < ActiveRecord::Migration
  def change
    create_table :actors_games, :id => false do |t|
      t.integer :actor_id
      t.integer :game_id
    end
  end
end
