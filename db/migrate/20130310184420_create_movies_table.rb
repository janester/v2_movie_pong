class CreateMoviesTable < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.string :title
      t.integer :year
      t.integer :tmdb_id
      t.integer :times_said, :default => 0
      t.timestamps
    end
  end
end
