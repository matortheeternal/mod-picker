class ModListPlugin < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache

  # SCOPES
  scope :official, -> (bool) {
    joins(:plugin => :mod).where(:mods => { is_official: bool })
  }

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'
  has_one :mod, :through => 'plugin'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'plugins_count'
  counter_cache_on :plugin, column: 'mod_lists_count'

  # VALIDATIONS
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :cleaned, :merged, inclusion: [true, false]
  # can only have a mod on a given mod list once
  validates :plugin_id, uniqueness: { scope: :mod_list_id, :message => "The plugin is already present on the mod list." }

  def required_plugins
    Master.plugins([self.plugin_id]).order(:master_plugin_id)
  end
end
