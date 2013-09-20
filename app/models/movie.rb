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


  def Movie.api_call(movie_id)
    response = JSON(RestClient.get("http://api.themoviedb.org/3/movie/#{movie_id}?api_key=#{TMDB}&append_to_response=casts", {:accept => "application/json"}))
    needed_info = {}
    needed_info[:title] = response["title"]
    needed_info[:year] = response["release_date"][0...4]
    needed_info[:tmdb_id] = response["id"]
    needed_info[:cast] = response["casts"]["cast"]
    needed_info[:popularity] = response["popularity"]
    return needed_info
  end


  def Movie.get_from_internet_and_add_cast_actors(movie_id)
    #find movie in db by tmdb_id
    movie = Movie.find_or_initialize_by_tmdb_id(movie_id)
    #call api (mostly to update popularity)
    results = Movie.api_call(movie_id)
    if results[:popularity] > 2
      #update movie information
      movie.update_attributes(title:results[:title], year:results[:year], tmdb_popularity:results[:popularity])
      #make sure the cast isn't already added
      movie.add_cast(results[:cast]) if movie.actors.length < 5
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
