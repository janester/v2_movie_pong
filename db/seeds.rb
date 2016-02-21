Movie.delete_all
Actor.delete_all
Game.delete_all
Score.delete_all
# User.delete_all

# puts "Creating User"
# u1 = User.create(:name => "Jane", :username => "janesternbach", :password => "abc", :password_confirmation => "abc")

def create_movie(movie)
  params = Movie.format_from_api(movie)
  Movie.create(params.merge(starting_movie: true))
end

puts "Fetching popular movies..."
movies = MovieDb.get_popular_movies.first(10)
movies.each do |movie_response|
  puts "Creating Movie: #{movie_response["title"]}"
  movie = create_movie(movie_response)
  movie.get_cast!
end
