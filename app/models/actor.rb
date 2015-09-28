# == Schema Information
#
# Table name: actors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tmdb_id    :integer
#  times_said :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Actor < ActiveRecord::Base
  attr_accessible :name, :tmdb_id, :popularity
  has_and_belongs_to_many :movies
  has_and_belongs_to_many :games
  validates :tmdb_id, :uniqueness => true
  validates :tmdb_id, :name, :presence => true


  def self.format_from_api(response)
    {
      name: response["name"],
      tmdb_id: response["id"],
      popularity: response["popularity"]
    }
  end

  def Actor.get_from_internet_and_filmography(actor_id)
    actor = Actor.find_or_initialize_by_tmdb_id(actor_id)
    results = Actor.api_call(actor_id)
    actor.update_attributes(name:results[:name], popularity:results[:popularity])
    actor.add_filmography_films(results[:films])
    puts "#{actor.name} and films have been added...".background(:black).foreground(:red).underline
  end



  def add_filmography_films(film_results)
    film_results.each do |movie|
      Movie.get_from_internet_and_add_cast_actors(movie["id"])
    end
  end
end
