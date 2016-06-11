class ConfigFile < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :game, :inverse_of => 'config_files'
  has_many :mod_list_config_files, :inverse_of => 'config_file'

  # Validations
  validates :game_id, :filename, :install_path, presence: true
end
