class AddFieldsToMovies < ActiveRecord::Migration
  def change
    add_column :movies, :starting_movie, :boolean, default: false
    add_column :movies, :full_cast_available, :boolean, default: false
  end
end
