class OverrideRecord < EnhancedRecord::Base
  self.primary_keys = :plugin_id, :fid

  belongs_to :plugin, :inverse_of => 'overrides'
  belongs_to :master, :inverse_of => 'overrides'

  # Validations
  validates :plugin_id, :form_id, :signature, presence: true
  validates :signature, length: {maximum: 4}
end
