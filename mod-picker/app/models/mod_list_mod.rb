class ModListMod < ActiveRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  self.primary_keys = :mod_list_id, :mod_id

  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  validates :mod_list_id, presence: true

  private
    # counter caches
    def increment_counter_caches
      self.mod_list.mods_count += 1
      self.mod_list.save
    end

    def decrement_counter_caches
      self.mod_list.mods_count -= 1
      self.mod_list.save
    end
end
