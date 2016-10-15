class ModListPlugin < ActiveRecord::Base
  include RecordEnhancements, BetterJson

  # Scopes
  scope :official, -> (bool) { joins(:plugin => :mod).where(:mods => { is_official: bool }) }

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'
  has_one :mod, :through => 'plugin'

  # VALIDATIONS
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :cleaned, :merged, inclusion: [true, false]
  # can only have a mod on a given mod list once
  validates :plugin_id, uniqueness: { scope: :mod_list_id, :message => "The plugin is already present on the mod list." }

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def required_plugins
    Master.plugins([self.plugin_id]).order(:master_plugin_id)
  end

  private
    def increment_counters
      self.mod_list.update_counter(:plugins_count, 1)
      self.plugin.update_counter(:mod_lists_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:plugins_count, -1)
      self.plugin.update_counter(:mod_lists_count, -1)
    end
end
