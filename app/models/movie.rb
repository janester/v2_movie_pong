# == Schema Information
#
# Table name: movies
#
#  id              :integer          not null, primary key
#  title           :string(255)
#  year            :integer
#  tmdb_id         :integer
#  times_said      :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  tmdb_popularity :integer          default(0)
#

class Movie < ActiveRecord::Base
  attr_accessible :title, :year, :tmdb_id, :tmdb_popularity, :times_said
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :games
  validates :tmdb_id, uniqueness: true

  scope :order_by_popularity, order("times_said DESC").order("tmdb_popularity DESC")
  scope :has_not_been_used, ->(said_movies) { where("id NOT IN (#{said_movies})") }

  class << self
    def create_or_find_movie(id)
      movie = find_by_tmdb_id(id)
      return movie if movie
      movie = MovieDb.get_movie(id)
      create(format_from_api(movie))
    end

    def format_from_api(response)
      {
        tmdb_id: response["id"],
        tmdb_popularity: response["popularity"],
        year: response["release_date"].try(:[], 0...4),
        title: response["title"]
      }
    end
  end

  def has_actor?(actor_id)
    return true if actors.pluck(:tmdb_id).include?(actor_id)
  end

  def add_if_new(actor)
    return if actors.include?(actor)
    actors << actor
  end

  def get_cast!
    cast_response = MovieDb.get_movie_credits(tmdb_id).select { |x| x[:character].present? }
    cast_response.map do |actor_response|
      actor = Actor.create_or_find_actor(actor_response[:id])
      add_if_new(actor)
    end
  end

  def increment_times_said!
    update_attributes(times_said: times_said + 1)
  end
end
