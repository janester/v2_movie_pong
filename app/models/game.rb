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

  def self.actor_in_movie?(actor, cast)
    if cast.map(&:name).include?(actor)
      index = cast.map(&:name).index(actor)
      puts "#{actor} IS in the movie...".background(:black).foreground(:red).underline
      return cast[index].tmdb_id
    else
      puts "#{actor} IS NOT in the movie".background(:black).foreground(:red).underline
      return nil
    end
  end # actor_in_movie?

  def actor_check(actor, movie_id)
    movie = Movie.where(tmdb_id: movie_id).first
    if movie.nil?
      movie = Movie.get_from_internet_and_add_cast_actors(movie_id)
    end
    cast = movie.actors
    actor_id = Game.actor_in_movie?(actor, cast)
    movie.times_said += 1
    movie.save
    movies << movie
    actor_id
  end # actor_check

  def actor_already_said?(id)
    actors.map(&:tmdb_id).include?(id)
  end

  def add_actor(actor_id)
    a = Actor.find_by_tmdb_id(actor_id)
    actors << a
    a
  end # add_actor

  def find_movie(actor)
    if actor.movies.length < 3
      Actor.get_from_internet_and_filmography(actor.tmdb_id)
    end
    movies = actor.movies.order("times_said DESC").order("tmdb_popularity DESC")
    new_movies = movies[0, 3].shuffle
    m = self.movies
    new_movies.reject! { |x| m.include?(x) }
    color_log "Possible movies to respond with: #{new_movies.map(&:title).join(", ")}"
    new_movies.length.sample
  end # find_movie

  def color_log(string)
    puts string.background(:black).foreground(:red).underline
  end
end # model
