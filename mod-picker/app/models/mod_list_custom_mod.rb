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

  def self.substitute_for_url(url, mod)
    uri = URI.parse(url)
    url = uri.host.gsub('\Awww\.', '') + uri.path
    ModListCustomMod.where("url LIKE ?", "%#{url}%").find_each do |custom_mod|
      ModListMod.create_from_custom_mod(custom_mod, mod)
      custom_mod.destroy
    end
  end

  def self.create_from_mod_list_mod(mod_list_mod)
    create({
        mod_list_id: mod_list_mod.mod_list_id,
        group_id: mod_list_mod.group_id,
        index: mod_list_mod.index,
        is_utility: mod_list_mod.is_utility,
        name: mod_list_mod.mod.name,
        url: mod_list_mod.mod.url,
        description: "Automatically created #{DateTime.now.to_s}"
    })
  end

  def copy_attributes(mod_list_id, index, group_id)
    attributes.except("id").merge({ mod_list_id: mod_list_id, index: index, group_id: group_id })
  end

  def copy_to(other_mod_list, index, new_group_id=nil)
    ModListCustomMod.create(copy_attributes(other_mod_list.id, index, new_group_id))
  end
end
