class ModListMod < ActiveRecord::Base
  include RecordEnhancements

  # SCOPES
  scope :utility, -> (bool) { joins(:mod).where(:mods => {is_utility: bool}) }
  scope :official, -> (bool) { joins(:mod).where(:mods => {is_official: bool}) }

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  # Validations
  validates :mod_list_id, :mod_id, :index, presence: true
  # can only have a mod on a given mod list once
  # TODO: If we don't allow the user to change the mod_id with nested attributes we could refactor this validation to be an after_create callback
  validates :mod_id, uniqueness: { scope: :mod_list_id, :message => "The mod is already present on the mod list." }

  # Callbacks
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  def self.install_order_json(collection)
    collection.as_json({
        :only => [:mod_id, :index],
        :include => {
            :mod => {
                :only => [:name]
            }
        }
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:id, :group_id, :index, :active],
          :include => {
              :mod => {
                  :only => [:id, :is_official, :name, :aliases, :authors, :status, :primary_category_id, :secondary_category_id, :average_rating, :reputation, :asset_files_count, :stars_count, :released, :updated],
                  :methods => :image
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def mod_compatibility_notes
    mod_ids = self.mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mod(mod_ids).mod([self.mod_id]).status([0, 1, 2])
  end

  def plugin_compatibility_notes
    mod_ids = self.mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    CompatibilityNote.visible.mods(mod_ids).mod([self.mod_id]).status([3, 4])
  end

  def install_order_notes
    mod_ids = self.mod_list.mod_list_mod_ids
    return [] if mod_ids.empty?

    InstallOrderNote.visible.mod(mod_ids).mod([self.mod_id])
  end

  def load_order_notes
    plugin_ids = self.mod_list.mod_list_plugin_ids
    return [] if plugin_ids.empty?

    LoadOrderNote.visible.plugin(plugin_ids).plugin(self.mod.plugins.ids)
  end

  def required_tools
    ModRequirement.mods(mod_id).utility(true)
  end

  def required_mods
    ModRequirement.mods(mod_id).utility(false)
  end

  private
    # counter caches
    def increment_counter_caches
      if self.mod.is_utility
        self.mod_list.update_counter(:tools_count, 1)
      else
        self.mod_list.update_counter(:mods_count, 1)
      end
      self.mod.update_counter(:mod_lists_count, 1)
    end

    def decrement_counter_caches
      if self.mod.is_utility
        self.mod_list.update_counter(:tools_count, -1)
      else
        self.mod_list.update_counter(:mods_count, -1)
      end
      self.mod.update_counter(:mod_lists_count, -1)
    end
end
