class PluginLoadOrderNote < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  self.primary_keys = :plugin_id, :load_order_note_id

  # ASSOCIATIONS
  belongs_to :plugin, :inverse_of => 'plugin_load_order_notes'
  has_one :mod, :through => :plugin
  belongs_to :load_order_note, :inverse_of => 'plugin_load_order_notes'
end