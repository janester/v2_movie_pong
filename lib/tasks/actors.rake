namespace "mp" do
  desc "Removes unpopular Actors from db"
  task :remove_actors => :environment do
    Actor.all.each do |actor|
      if actor.movies.length < 3
        Actor.delete(actor.id)
      end
    end
  end
end
