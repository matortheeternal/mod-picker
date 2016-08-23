class PluginError < ActiveRecord::Base
  include ScopeHelpers

  # Scopes
  ids_scope :plugin_id

  # Associations
  belongs_to :plugin, :inverse_of => 'errors'

  # Validations
  validates :signature, :form_id, :group, presence: true

  validates :signature, length: {is: 4}
  validates :path, :name, length: {maximum: 400}
  validates :data, length: {maximum: 255}

  belongs_to :plugin, :inverse_of => 'plugin_errors'
end
