class UserTitle < ActiveRecord::Base
  include Filterable

  scope :game, -> (game) { where(game_id: game) }

  belongs_to :game

  # VALIDATIONS
  validates :game_id, :title, :rep_required, presence: true
  validates :title, length: {maximum: 32}
end
