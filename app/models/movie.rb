# == Schema Information
#
# Table name: movies
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  year            :integer
#  tmdb_id         :integer
#  times_said      :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  tmdb_popularity :integer          default(0)
#

class Movie < ActiveRecord::Base
  attr_accessible :title, :year, :tmdb_id, :tmdb_popularity
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :games
  validates :tmdb_id, :uniqueness => true

  scope :order_by_popularity, order("times_said DESC").order("tmdb_popularity DESC")
  scope :has_not_been_used, ->(said_movies) { where("id NOT IN (#{said_movies})") }

  def has_actor?(actor_id)
    return true if actors.pluck(:tmdb_id).include?(actor_id)
    retrieve_cast.any? {|actor| actor["id"] == actor_id}
  end

  def self.format_from_api(response)
    {
      tmdb_id: response["id"],
      tmdb_popularity: response["popularity"],
      year: response["release_date"][0...4],
      title: response["title"]
    }
  end

  def retrieve_cast
    MovieDb.get_movie_credits(tmdb_id)
  end


  def Movie.get_from_internet_and_add_cast_actors(movie_id)
    #find movie in db by tmdb_id
    movie = Movie.find_or_initialize_by_tmdb_id(movie_id)
    #call api (mostly to update popularity)
    results = Movie.api_call(movie_id)
    if (results[:popularity] > 2) && (results[:release].to_date.past?)
      #update movie information
      movie.update_attributes(title:results[:title], year:results[:year], tmdb_popularity:results[:popularity])
      #make sure the cast isn't already added
      movie.add_cast(results[:cast])
      puts "#{movie.title} and actors have been added".background(:black).foreground(:red).underline
      return movie
    else
      return nil
    end
  end


  def add_cast(cast_results)
    puts "adding cast to #{self.title}...".background(:black).foreground(:red).underline
    #only go the db once to get the actors
    movie_actors = self.actors
    cast_results.each do |actor|
      #downcase name to make sure all input is sanitized
      name = actor["name"].downcase
      #find actor in the db by tmdb_id
      a = Actor.find_or_initialize_by_tmdb_id(actor["id"])
      #update actor info if there isn't any
      a.update_attributes(name:name) if a.name.nil?
      unless movie_actors.include?(a)
        #add the actor to the array of actors for this movie
        puts "#{name} is being added to #{self.title}".background(:black).foreground(:red).underline
        movie_actors << a
      end
    end
  end

end
