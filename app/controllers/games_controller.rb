class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.create
    @current_user.games << game
    redirect_to(start_game_path(game.id))
  end

  def play
    movie = params[:movie].to_i
    actor = params[:actor]
    game = Game.find(params[:id])
    actor_id = game.is_actor_in_movie(actor, movie)
    if actor_id.present?
      if game.actor_has_been_said?(actor_id)
        game.scores << Score.create(:player => 1)
        render :json => {scores:game.scores, message:"Sorry! #{actor} was already said."}
      else
        actor = game.add_actor(actor_id)
        movie = game.find_movie(actor)
        if movie.nil?
          game.scores << Score.create(:computer => 1)
          render :json => {scores:game.scores, message:"Congrats! You beat me this round! I couldn't find any movies that #{actor.name} has been in that haven't already been said."}
        else
          render :json => {movie:movie, scores:game.scores}
        end

      end
    else
      game.scores << Score.create(:player => 1)
      render :json => {scores:game.scores, message:"Sorry! #{actor} wasn't in #{game.movies.last.title}"}
    end

  end

  def start
    @game = Game.find(params[:id])
  end

  def get_info
    game = Game.find(params[:id])
    movies = Movie.order("times_said DESC").order("tmdb_popularity DESC")
    movies = movies.reject{|movie| game.movies.include?(movie)}
    movies = movies[0,20].shuffle
    render :json => movies
  end
end
