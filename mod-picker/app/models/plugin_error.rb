class PluginError < EnhancedRecord::Base
  belongs_to :plugin, :inverse_of => 'errors'

  # Validations
  validates :plugin_id, :signature, :form_id, :group, presence: true
  validates :signature, length: {maximum: 4}

  belongs_to :plugin, :inverse_of => 'plugin_errors'
end
