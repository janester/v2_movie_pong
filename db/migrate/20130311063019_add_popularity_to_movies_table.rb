class AddPopularityToMoviesTable < ActiveRecord::Migration
  def change
    add_column(:movies, :tmdb_popularity, :integer, :default => 0)
  end
end
