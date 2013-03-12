# == Schema Information
#
# Table name: actors
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tmdb_id    :integer
#  times_said :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Actor < ActiveRecord::Base
  attr_accessible :name, :tmdb_id
  has_and_belongs_to_many :movies
  has_and_belongs_to_many :games
  validates :tmdb_id, :uniqueness => true

  def Actor.get_from_internet_and_filmography(actor_id)
    #get actor from internet
    actor_blob = Actor.get_info(actor_id)
    #make actor if not yet existing
    actor_hash = Actor.add_actor(actor_id, actor_blob)
    actor = actor_hash[:actor]
    filmography = actor_hash[:films]
    #got through filmography making movies
    films = Actor.add_filmography_films(filmography)
    act = {}
    act[:actor] = actor
    act[:films] = films
    return act
  end

  def Actor.get_info(actor_id)
    begin
      actor = HTTParty.get("http://api.themoviedb.org/2.1/Person.getInfo/en/json/#{TMDB}/#{actor_id}")
    rescue
      retry
    end
    return actor
  end

  def Actor.add_actor(actor_id, actor_blob)
    if Actor.exists?(:tmdb_id => actor_id)
      actor = Actor.where(:tmdb_id => actor_id).first
    else
      name = actor_blob[0]["name"]
      tmdb_id = actor_blob[0]["id"]
      actor = Actor.create(:name => name, :tmdb_id => tmdb_id)
    end
    filmography = actor_blob[0]["filmography"]
    a = {}
    a[:actor] = actor
    a[:films] = filmography
    return a
  end

  def Actor.add_filmography_films(filmography)
    films = []
    filmography.each do |movie|
      m = Movie.get_from_internet_and_add_cast_actors(movie["id"])
      films << m[:movie] if m.present?
    end
    return films
  end

end
