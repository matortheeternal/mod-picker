class PluginError < ActiveRecord::Base
  # Scopes
  scope :plugins, -> (plugin_ids) { where(plugin_id: plugin_ids) }

  # Associations
  belongs_to :plugin, :inverse_of => 'errors'

  # Validations
  validates :signature, :form_id, :group, presence: true

  validates :signature, length: {is: 4}
  validates :path, :name, length: {maximum: 400}
  validates :data, length: {maximum: 255}

  belongs_to :plugin, :inverse_of => 'plugin_errors'
end
