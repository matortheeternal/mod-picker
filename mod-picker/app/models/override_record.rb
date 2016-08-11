class OverrideRecord < ActiveRecord::Base
  self.primary_keys = :plugin_id, :fid

  # Scopes
  scope :plugins, -> (plugin_ids) { where(plugin_id: plugin_ids) }

  # Associations
  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'

  # Validations
  validates :fid, :sig, presence: true
  validates :sig, length: {is: 4}
end
