class AddPopularityToActors < ActiveRecord::Migration
  def change
    add_column :actors, :popularity, :float
  end
end
