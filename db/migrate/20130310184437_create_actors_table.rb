class CreateActorsTable < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.string :name
      t.integer :tmdb_id
      t.integer :times_said, :default => 0
      t.timestamps
    end
  end
end
