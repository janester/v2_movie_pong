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
      if movie.year > 2013
        Movie.delete(movie.id)
      end
    end
  end
end
