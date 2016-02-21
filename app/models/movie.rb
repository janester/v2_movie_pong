# == Schema Information
#
# Table name: movies
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  year                :integer
#  tmdb_id             :integer
#  times_said          :integer          default(0)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  tmdb_popularity     :integer          default(0)
#  starting_movie      :boolean          default(FALSE)
#  full_cast_available :boolean          default(FALSE)
#

class Movie < ActiveRecord::Base
  include MoviePong::Common
  attr_accessible :title, :year, :tmdb_id, :tmdb_popularity, :times_said, :full_cast_available, :starting_movie
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :games
  validates :tmdb_id, uniqueness: true

  scope :order_by_popularity, order("times_said DESC").order("tmdb_popularity DESC")
  scope :has_not_been_used, ->(said_movies) { where("id NOT IN (#{said_movies.join(",")})") }
  scope :starting_movies, where(starting_movie: true)

  class << self
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

  def get_cast!
    return if full_cast_available
    get_characters.map { |a| add_actor(a) }
    update_attributes(full_cast_available: true)
  end

  def add_actor(params)
    actor = Actor.create_or_find(params[:id], params)
    add_if_new(actor)
    actor
  end

  def get_characters
    retrieve_credits.select { |x| x[:character].present? }
  end

  def retrieve_credits
    credits = MovieDb.get_movie_credits(tmdb_id)
    credits.is_a?(Array) ? credits : []
  end

  def increment_times_said!
    update_attributes(times_said: times_said + 1)
  end

  def decrement_times_said!
    update_attributes(times_said: times_said - 2)
  end
end
