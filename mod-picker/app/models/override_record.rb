class OverrideRecord < ActiveRecord::Base
  self.primary_keys = :plugin_id, :fid

  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'

  # Validations
  validates :fid, :sig, presence: true
  validates :sig, length: {is: 4}
end
