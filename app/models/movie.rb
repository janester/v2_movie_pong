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

  def Movie.get_from_internet_and_add_cast_actors(movie_id)
    #get movie
    movie_obj = Movie.get_movie(movie_id)
    #make movie object if it doesn't yet exist
    movie_hash = Movie.add_movie(movie_id, movie_obj)
    if movie_hash.present?
      movie = movie_hash[:movie]
      cast = movie_hash[:cast]
      #go through cast making objects (if not yet existing) and making relationships(if not yet existing)
      Movie.add_cast(movie, cast)
      movie.actors = movie.actors.uniq
      mov = {}
      mov[:movie] = movie
      mov[:cast] = movie.actors
      return mov
    else
      return nil
    end
  end

  def Movie.get_movie(movie_id)
    begin
      movie = TmdbMovie.find(:id => movie_id)
    rescue
      retry
    end
    return movie
  end

  def Movie.add_movie(movie_id, movie_obj)
    movie = movie_obj
    if movie.length.nil?
      cast = movie.cast.select {|i| i.job == "Actor"}
      a = movie.name
      b = movie.released[0,4] if movie.released.present?
      c = movie.id
      d = movie.popularity
    else
      cast = movie[0].cast.select {|i| i.job == "Actor"}
      a = movie[0].name
      b = movie[0].released[0,4] if movie[0].released.present?
      c = movie[0].id
      d = movie[0].popularity
    end
    if Movie.exists?(:tmdb_id => movie_id)

      m = {}
      m[:movie] = Movie.where(:tmdb_id => movie_id).first
      m[:cast] = cast
      return m
    else
      if d > 2 && b.present?
        new_movie = Movie.create(:title => a, :year => b, :tmdb_id => c, :tmdb_popularity => d)
        m = {}
        m[:movie] = new_movie
        m[:cast] = cast
        return m
      else
        return nil
      end
    end
  end

  def Movie.add_cast(movie, cast)
    cast.each do |actor|
      if Actor.exists?(:tmdb_id => actor.id)
        actor_obj = Actor.where(:tmdb_id => actor.id).first
      else
        actor_obj = Actor.create(:name => actor.name.downcase, :tmdb_id => actor.id)
      end
      movie.actors << actor_obj unless movie.actors.include?(actor_obj)
    end
  end

end
