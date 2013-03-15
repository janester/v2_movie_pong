# == Schema Information
#
# Table name: games
#
#  id                   :integer          not null, primary key
#  final_computer_score :integer
#  final_player_score   :integer
#  winner               :integer
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Game < ActiveRecord::Base
  attr_accessible :final_computer_score, :final_player_score, :winner, :user_id
  belongs_to :user
  has_many :scores
  has_and_belongs_to_many :movies
  has_and_belongs_to_many :actors


  def Game.is_actor_in_movie(actor, cast)
    if cast.map(&:name).include?(actor)
      index = cast.map(&:name).index(actor)
      return actor_id = cast[index].tmdb_id
    else
      return actor_id = nil
    end
  end

  def actor_check(actor, movie_id)
    if Movie.exists?(:tmdb_id => movie_id)
      movie = Movie.where(:tmdb_id => movie_id).first
      cast = movie.actors
      a_id = Game.is_actor_in_movie(actor, cast)
      if a_id.present?
        actor_id = a_id
      else
        m = Movie.get_from_internet_and_add_cast_actors(movie_id)
        movie = m[:movie]
        cast = m[:cast]
        actor_id = Game.is_actor_in_movie(actor, cast)
      end
    else
      m = Movie.get_from_internet_and_add_cast_actors(movie_id)
      movie = m[:movie]
      cast = m[:cast]
      actor_id = Game.is_actor_in_movie(actor, cast)
    end
    self.movies << movie
    movie.times_said += 1
    movie.save
    return actor_id
  end

  def actor_has_been_said?(actor_id)
    self.actors.map(&:tmdb_id).include?(actor_id)
  end

  def add_actor(actor_id)
    a = Actor.where(:tmdb_id => actor_id).first
    self.actors << a
    return a
  end

  def find_movie(actor)
    if actor.movies.length < 3
      a = Actor.get_from_internet_and_filmography(actor.tmdb_id)
    end
    movies = actor.movies.order("times_said DESC").order("tmdb_popularity DESC")
    new_movies = movies[0,3].shuffle
    # new_movies << movies.sample
    # new_movies = new_movies.shuffle
    new_movies.reject!{|x| self.movies.include?(x)}
    if movies.length == 0
      return nil
    else
      return new_movies[0]
    end
  end



end
