class PluginError < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'errors'

  # Validations
  validates :plugin_id, :signature, :form_id, :type, presence: true
  validates :signature, length: {maximum: 4}
end
