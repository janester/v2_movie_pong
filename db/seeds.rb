User.delete_all
Movie.delete_all
Actor.delete_all
Game.delete_all
Score.delete_all

u1 = User.create(:name => "Jane", :username => "janesternbach", :password => "abc", :password_confirmation => "abc")


popular_movie_ids = Tmdb::Movie.popular.map{|x| x["id"]}
puts "ADDING MOVIES:"
puts
popular_movie_ids.each do |id|
  Movie.get_from_internet_and_add_cast_actors(id)
end

popular_people_ids = Tmdb::People.popular.map{|x| x["id"]}
puts "ADDING PEOPLE:"
puts
popular_people_ids.each do |id|
  Actor.get_from_internet_and_filmography(id)
end