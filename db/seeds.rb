Movie.delete_all
Actor.delete_all
Game.delete_all
Score.delete_all
# User.delete_all

# puts "Creating User"
# u1 = User.create(:name => "Jane", :username => "janesternbach", :password => "abc", :password_confirmation => "abc")

def create_movie(movie)
  params = Movie.format_from_api(movie)
  Movie.create(params)
end

def create_cast(movie)
  cast = MovieDb.get_movie_credits(movie.tmdb_id).select { |x| x["character"].present? }
  puts "CAST COUNT: #{cast.count}"
  cast.each_with_index do |actor_response, i|
    puts "Creating Actor: #{actor_response["name"]}"
    actor = find_or_get_actor(actor_response[:id])
    movie.actors << actor
    sleep 5 if i%20 == 0
  end
end

def find_or_get_actor(id)
  actor = Actor.find_by_tmdb_id(id)
  return actor if actor
  actor = MovieDb.get_actor(id)
  Actor.create(Actor.format_from_api(actor))
end

puts "Fetching popular movies..."
movies = MovieDb.get_popular_movies
movies.each do |movie_response|
  puts "Creating Movie: #{movie_response["title"]}"
  movie = create_movie(movie_response)
  create_cast(movie)
end
