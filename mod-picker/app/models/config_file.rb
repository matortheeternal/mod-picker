class ConfigFile < ActiveRecord::Base
  include CounterCacheEnhancements

  belongs_to :game, :inverse_of => 'config_files'

  # Validations
  validates :game_id, :filename, :install_path, presence: true
end
