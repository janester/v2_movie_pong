class GamesController < ApplicationController
  HARDNESS_LIMIT = 3
  before_filter :populate_scores
  before_filter :set_last_actor, only: [:get_info]
  before_filter :increment_round, only: [:play, :dont_know]
  before_filter :add_movie_to_game, only: [:play, :dont_know]
  before_filter :increment_movie_times_said, only: [:play]

  def index
  end

  def create
    @game = Game.create(user_id: @current_user.id)
    session[:round] = 1
    session[:player_score] = 0
    session[:computer_score] = 0
    redirect_to(start_game_path(@game.id))
  end

  def play
    return actor_not_in_movie unless movie.has_actor?(actor_id)
    return actor_already_said if game.actor_already_said?(actor_id)
    game.add_actor(actor)
    new_movie = get_next_movie
    return no_more_popular_movies unless new_movie
    new_movie.get_cast!
    render json: { scores: score_serializer, movie: new_movie, actors: actors }
  end

  def dont_know
    movie.decrement_times_said!
    game.point_for(:player)
    render json: { scores: score_serializer, message: "Okay, let's start a new round" }
  end

  def get_next_movie
    actor.get_movies!
    possible_movies = actor.movies.order_by_popularity.limit(HARDNESS_LIMIT)
    (possible_movies - game.movies).sample
  end

  def actor_id
    params[:actor_id].to_i
  end

  def no_more_popular_movies
    game.point_for(:computer)
    render json: { scores: score_serializer, message: "Nice! You out-witted a computer!" }
  end

  def add_movie_to_game
    game.movies << movie
  end

  def increment_movie_times_said
    movie.increment_times_said!
  end

  def increment_round
    session[:round] += 1
  end

  def actor_already_said
    game.point_for(:player)
    render json: { scores: score_serializer, message: "#{actor.name} has already been said" }
  end

  def actor_not_in_movie
    game.point_for(:player)
    render json: { scores: score_serializer, message: "#{actor.name} is not in #{movie.title}" }
  end

  def start
    game
  end

  def get_info
    render json: { movies: starting_movies, actors: actors }
  end

  def starting_movies
    movies = Movie.starting_movies
    movies = movies.has_not_been_used(game.said_movies) unless game.movies.empty?
    movies.shuffle
  end

  def actors
    Actor.select("name, tmdb_id")
  end

  def score_serializer
    game.scores.select("computer, player")
  end

  private

  def movie
    @movie ||= Movie.find_by_tmdb_id(params[:movie_id])
  end

  def actor
    @actor ||= Actor.find_by_tmdb_id(params[:actor_id])
  end

  def set_last_actor
    session[:last_actor] = Actor.last.try(:id)
  end

  def game
    @game ||= Game.includes(:movies, :scores).find(params[:id])
  end

  def populate_scores
    return unless params[:id]
    game.scores.each do |score|
      increment_score(:player) if score.for_player?
      increment_score(:computer) if score.for_computer?
    end
  end

  def increment_score(player)
    player = "#{player}_score"
    session[player] = session[player].to_i + 1
  end
end
