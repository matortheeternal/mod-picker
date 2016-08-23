class UserTitle < ActiveRecord::Base
  include Filterable, ScopeHelpers

  game_scope

  belongs_to :game

  # Validations
  validates :game_id, :title, :rep_required, presence: true
  validates :title, length: {maximum: 32}
end
