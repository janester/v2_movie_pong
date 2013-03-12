# == Schema Information
#
# Table name: scores
#
#  id         :integer          not null, primary key
#  computer   :integer          default(0)
#  player     :integer          default(0)
#  game_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Score < ActiveRecord::Base
  attr_accessible :computer, :player
  belongs_to :game
end
