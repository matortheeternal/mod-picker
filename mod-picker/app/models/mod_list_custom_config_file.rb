class ModListCustomConfigFile < ActiveRecord::Base
  include BetterJson, CounterCache

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'custom_config_files'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'custom_config_files_count'

  # VALIDATIONS
  validates :mod_list_id, :filename, :install_path, presence: true
  validates :text_body, length: {maximum: 8192}

  def copy_attributes(mod_list_id)
    attributes.except("id").merge({ mod_list_id: mod_list_id })
  end

  def copy_to(other_mod_list)
    ModListCustomConfigFile.create(copy_attributes(other_mod_list.id))
  end
end
