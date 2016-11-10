class OverrideRecord < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :plugin_id, :fid

  # Scopes
  ids_scope :plugin_id

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'

  # VALIDATIONS
  validates :fid, :sig, presence: true
  validates :sig, length: {is: 4}
end
