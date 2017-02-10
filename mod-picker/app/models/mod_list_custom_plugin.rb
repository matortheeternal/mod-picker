class ModListCustomPlugin < ActiveRecord::Base
  include BetterJson, CounterCache, ScopeHelpers

  # SCOPES
  nil_scope :group_id, alias: 'orphans'

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'custom_plugins'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'custom_plugins_count'

  # VALIDATIONS
  validates :mod_list_id, :index, :filename, presence: true
  validates :merged, :cleaned, inclusion: [true, false]
  validates :filename, length: {maximum: 255}
  validates :description, length: {maximum: 4096}

  def copy_attributes(mod_list_id, index, group_id)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index, group_id: group_id })
  end

  def copy_to(other_mod_list, index, new_group_id=nil)
    ModListCustomPlugin.create(copy_attributes(other_mod_list.id, index, new_group_id))
  end
end
