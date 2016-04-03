class ConfigFile < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'config_files'
end
