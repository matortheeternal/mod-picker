class ConfigFile < ActiveRecord::Base
  include RecordEnhancements, BetterJson

  belongs_to :game, :inverse_of => 'config_files'
  belongs_to :mod, :inverse_of => 'config_files'
  has_many :mod_list_config_files, :inverse_of => 'config_file'

  # VALIDATIONS
  validates :filename, :install_path, presence: true

  # CALLBACKS
  before_create :set_game_id

  private
    def set_game_id
      self.game_id = mod.game_id
    end
end
