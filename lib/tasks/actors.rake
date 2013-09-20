namespace "mp" do
  desc "Removes unpopular Actors from db"
  task :remove_actors => :environment do
    Actor.all.each do |actor|
      if actor.movies.length < 3
        Actor.delete(actor.id)
      end
    end
  end
  desc "Removes not yet released Movies from db"
  task :remove_movies => :environment do
    Movie.all.each do |movie|
      if movie.year > Date.today.year
        Movie.delete(movie.id)
      end
    end
  end

  desc "add popular movies"
  task :popular_movies => :environment do
    popular_movie_ids = Tmdb::Movie.popular.map{|x| x["id"]}
    puts "ADDING MOVIES:"
    puts
    popular_movie_ids.each do |id|
      Movie.get_from_internet_and_add_cast_actors(id)
    end
  end
  desc "add popular actors"
  task :popular_actors => :environment do
    popular_people_ids = Tmdb::People.popular.map{|x| x["id"]}
    puts "ADDING PEOPLE:"
    puts
    popular_people_ids.each do |id|
      Actor.get_from_internet_and_filmography(id)
    end
  end
  desc "ping site"
  task :ping_site => :environment do
    if (Time.now.hour < 23) && (Time.now.hour > 9)
      uri = URI.parse('http://moviepongv2.herokuapp.com/')
      Net::HTTP.get(uri)
      puts "Movie Pong has been pinged..."
    end
  end
end
