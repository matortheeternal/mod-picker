class RecordGroup < ActiveRecord::Base
  include BetterJson, ScopeHelpers

  # SCOPES
  game_scope

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'record_groups'

  # VALIDATIONS
  validates :game_id, :signature, :name, presence: true
  validates :signature, length: {is: 4}
  validates :name, length: {maximum: 64}
end
