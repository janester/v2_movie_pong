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
  desc "ping site"
  task :ping_site => :environment do
    if (Time.now.hour < 23) && (Time.now.hour > 9)
      uri = URI.parse('http://barcodenyc.herokuapp.com/')
      Net::HTTP.get(uri)
      puts "Barcode has been pinged..."
    end
  end
end
