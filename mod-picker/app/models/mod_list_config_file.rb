class ModListConfigFile < EnhancedRecord::Base
  self.primary_keys = :mod_list_id, :config_file_id

  belongs_to :mod_list, :inverse_of => 'config_files'

  # validations
  validates :mod_list_id, :config_file_id, presence: true
  validates :text_body, length: { maximum: 4096}
end
