class AddIndexToTmdbId < ActiveRecord::Migration
  def change
    add_index(:actors, :tmdb_id)
    add_index(:movies, :tmdb_id)
  end
end
