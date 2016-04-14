class UserTitle < ActiveRecord::Base
  include Filterable

  scope :game, -> (game) { where(game_id: game) }

  belongs_to :game
end
