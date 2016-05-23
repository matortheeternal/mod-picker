class ConfigFile < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :game, :inverse_of => 'config_files'

  # Validations
  validates :game_id, :filename, :install_path, presence: true
end
