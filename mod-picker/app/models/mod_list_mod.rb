class ModListMod < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  # Validations
  validates :mod_list_id, :mod_id, :index, presence: true
  validates :active, inclusion: [true, false]
  validates :mod_list_id, presence: true
  # can only have a mod on a given mod list once
  validates :mod_id, uniqueness: { scope: :mod_list_id, :message => "The mod is already present on the mod list." }

  # Callbacks
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

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
