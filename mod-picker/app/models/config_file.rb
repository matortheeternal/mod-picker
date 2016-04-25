class ConfigFile < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'config_files'
  validates :game_id, :filename, :install_path, presence: true
end
