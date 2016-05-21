class ModListCustomConfigFile < EnhancedRecord::Base
  belongs_to :mod_list, :inverse_of => 'custom_config_files'

  # validations
  validates :mod_list_id, :filename, :install_path, presence: true
  validates :text_body, length: {maximum: 4096}
end
