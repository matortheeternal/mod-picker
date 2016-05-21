class ModListPlugin < ActiveRecord::Base

  self.primary_keys = :mod_list_id, :plugin_id

  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'

  # Validations
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :active, inclusion: [true, false]

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

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
