class ModListCustomMod < ActiveRecord::Base
  include RecordEnhancements, ScopeHelpers, BetterJson, CounterCache

  # SCOPES
  value_scope :is_utility
  nil_scope :group_id, alias: 'orphans'

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'custom_mods'

  # COUNTER CACHE
  bool_counter_cache_on :mod_list, :is_utility, { true => :custom_tools, false => :custom_mods }

  # VALIDATIONS
  validates :mod_list_id, :index, :name, presence: true
  validates :is_utility, inclusion: [true, false]
  validates :description, length: {maximum: 4096}

  def copy_attributes(mod_list_id, index, group_id)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index, group_id: group_id })
  end

  def copy_to(other_mod_list, index, new_group_id=nil)
    ModListCustomMod.create(copy_attributes(other_mod_list.id, index, new_group_id))
  end
end
