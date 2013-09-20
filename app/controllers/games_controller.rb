class GamesController < ApplicationController
  def index
  end

  def create
    game = Game.create(user_id:@current_user.id)
    session[:round] = 1
    redirect_to(start_game_path(game.id))
  end

  def play
    movie = params[:movie].to_i
    actor = params[:actor].downcase
    game = Game.find(params[:id])
    actor_id = game.actor_check(actor, movie)
    if actor_id.present?
      if game.actor_has_been_said?(actor_id)
        game.scores << Score.create(:player => 1)
        session[:round] +=1
        render :json => {scores:game.scores, message:"Sorry! #{actor.titleize} was already said."}
      else
        actor = game.add_actor(actor_id)
        movie = game.find_movie(actor)
        if movie.nil?
          game.scores << Score.create(:computer => 1)
          session[:round] +=1
          render :json => {scores:game.scores, message:"Congrats! You beat me this round! I couldn't find any movies that #{actor.name} has been in that haven't already been said."}
        else
          actors = Actor.where("id BETWEEN #{session[:last_actor]+1} AND #{Actor.last.id}").map(&:name)
          session[:last_actor] = Actor.last.id
          render :json => {movie:movie, scores:game.scores, actors:actors}
        end
      end
    else
      session[:round] +=1
      if actor == ""
        message = "Sorry! You got a point!"
      else
        movie = Movie.where(:tmdb_id => movie).first.title
        message = "Sorry! #{actor.titleize} wasn't in #{movie}"
      end
      game.scores << Score.create(:player => 1)
      render :json => {scores:game.scores, message:message}
    end
  end

  def start
    @game = Game.find(params[:id])
    scores = @game.scores
    unless scores.empty?
      @p = @c = 0
      scores.each do |score|
        score.computer == 0 ? @p +=1 : @c +=1
      end
    end
  end

  def get_info
    game = Game.find(params[:id])
    said_movies = game.movies
    if said_movies.empty?
      movies = Movie.order("times_said DESC").order("tmdb_popularity DESC")
    else
      said_movies = said_movies.map(&:id).join(", ")
      movies = Movie.order("times_said DESC").order("tmdb_popularity DESC").where("id NOT IN (#{said_movies})")
    end
    movies = movies[0,20].shuffle
    session[:last_actor] = Actor.last.id
    render :json => {movies:movies, actors:Actor.all.map{|x| x.name}}
  end
end
