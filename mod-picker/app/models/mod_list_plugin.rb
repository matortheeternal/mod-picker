class ModListPlugin < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'
  has_one :mod, :through => 'plugin'

  # Validations
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :active, inclusion: [true, false]
  # can only have a mod on a given mod list once
  validates :plugin_id, uniqueness: { scope: :mod_list_id, :message => "The plugin is already present on the mod list." }

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      # TODO: Revise this as necessary
      default_options = {
          :only => [:index, :group_id, :active],
          :include => {
              :plugin => {
                  :except => [:game_id, :mod_id, :description, :mod_lists_count, :load_order_notes_count]
              },
              :mod => {
                  :only => [:id, :name, :primary_category_id, :secondary_category_id]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
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
