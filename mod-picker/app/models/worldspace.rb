class Worldspace < ActiveRecord::Base
  include BetterJson, ScopeHelpers

  # SCOPES
  game_scope

  # ASSOCIATIONS
  belongs_to :game
  belongs_to :plugin

  has_many :cells
end
