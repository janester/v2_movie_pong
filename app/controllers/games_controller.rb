class GamesController < ApplicationController
  before_filter :populate_scores
  before_filter :set_last_actor, only: [:get_info]

  def index
  end

  def create
    game = Game.create(user_id:@current_user.id)
    session[:round] = 1
    redirect_to(start_game_path(game.id))
  end

  def play
    # actor in movie?
    # actor in been said?

    # movie = params[:movie].to_i
    # actor = params[:actor].downcase
    # actor_id = game.actor_check(actor, movie)
    # if actor_id.present?
    #   if game.actor_has_been_said?(actor_id)
    #     game.scores << Score.create(:player => 1)
    #     session[:round] +=1
    #     render :json => {scores:game.scores, message:"Sorry! #{actor.titleize} was already said."}
    #   else
    #     actor = game.add_actor(actor_id)
    #     movie = game.find_movie(actor)
    #     if movie.nil?
    #       game.scores << Score.create(:computer => 1)
    #       session[:round] +=1
    #       render :json => {scores:game.scores, message:"Congrats! You beat me this round! I couldn't find any movies that #{actor.name.titleize} has been in that haven't already been said."}
    #     else
    #       actors = Actor.where("id BETWEEN #{session[:last_actor]+1} AND #{Actor.last.id}").map(&:name)
    #       session[:last_actor] = Actor.last.id
    #       render :json => {movie:movie, scores:game.scores, actors:actors}
    #     end
    #   end
    # else
    #   session[:round] +=1
    #   if actor == ""
    #     movie = Movie.find_by_tmdb_id(movie)
    #     movie.times_said -= 1
    #     movie.save
    #     message = "Sorry! You got a point!"
    #   else
    #     movie = Movie.where(:tmdb_id => movie).first.title
    #     message = "Sorry! #{actor.titleize} wasn't in #{movie}"
    #   end
    #   game.scores << Score.create(:player => 1)
    #   render :json => {scores:game.scores, message:message}
    # end

    session[:round] +=1
    return "Sorry! #{params[:actor]} was not in #{movie.title}" unless movie.has_actor?(actor)
  end

  def run_game

  end

  def search_for_actor

  end

  def start
    @game = Game.find(params[:id])
  end

  def get_info
    movies = Movie.order_by_popularity
    movies.has_not_been_used(said_movies) if said_movies
    movies = movies.first(20).shuffle
    render :json => {movies:movies, actors: Actor.select("name, tmdb_id")}
  end


  private

  def said_movies(g = nil)
    (g || game).movies.pluck(:id)
  end

  def movie
    @movie ||= Movie.find(params[:movie])
  end

  def set_last_actor
    session[:last_actor] = Actor.last.id
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
