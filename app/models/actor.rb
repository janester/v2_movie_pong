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
#  popularity :float
#

class Actor < ActiveRecord::Base
  include MoviePong::Common
  CURRENT_YEAR = DateTime.now.year

  attr_accessible :name, :tmdb_id, :popularity, :times_said
  has_and_belongs_to_many :movies
  has_and_belongs_to_many :games
  validates :tmdb_id, uniqueness: true
  validates :tmdb_id, :name, presence: true

  def self.format_from_api(response)
    {
      name: response["name"],
      tmdb_id: response["id"],
      popularity: response["popularity"]
    }
  end

  def increment_times_said!
    update_attributes(times_said: times_said + 1)
  end

  def retrieve_filmography
    movie_responses = MovieDb.get_actor_credits(tmdb_id)
    movie_responses.is_a?(Array) ? movie_responses : []
  end

  def released_in_the_future?(x)
    release_date = DateTime.parse(x)
    release_date.future?
  rescue
    true
  end

  def ordered_filmography
    past_films = retrieve_filmography.reject { |x| released_in_the_future?(x["release_date"]) }
    past_films.sort_by { |x| DateTime.parse(x["release_date"]) }.reverse
  end

  def get_movies!
    ordered_filmography.first(15).map { |m| add_movie(m) }
  end

  def add_movie(m)
    movie = Movie.create_or_find(m[:id], m)
    add_if_new(movie)
    movie
  end
end
