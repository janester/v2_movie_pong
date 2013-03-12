class CreateGamesMoviesTable < ActiveRecord::Migration
  def change
    create_table :games_movies, :id => false do |t|
      t.integer :game_id
      t.integer :movie_id
    end
  end
end
