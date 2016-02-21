# == Schema Information
#
# Table name: games
#
#  id                   :integer          not null, primary key
#  final_computer_score :integer
#  final_player_score   :integer
#  winner               :integer
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Game < ActiveRecord::Base
  attr_accessible :final_computer_score, :final_player_score, :winner, :user_id
  belongs_to :user
  has_many :scores
  has_and_belongs_to_many :movies
  has_and_belongs_to_many :actors

  def actor_already_said?(id)
    actors.map(&:tmdb_id).include?(id)
  end
end
