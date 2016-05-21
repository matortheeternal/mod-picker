class Game < EnhancedRecord::Base
  has_many :mods, :inverse_of => 'game'
  has_many :nexus_infos, :inverse_of => 'game'
  has_many :lover_infos, :inverse_of => 'game'
  has_many :mod_lists, :inverse_of => 'game'
  has_many :config_files, :inverse_of => 'game'
  has_many :asset_files, :inverse_of => 'game'
  has_many :compatibility_notes, :inverse_of => 'game'
  has_many :incorrect_notes, :inverse_of => 'game'
  has_many :install_order_notes, :inverse_of => 'game'
  has_many :load_order_notes, :inverse_of => 'game'
  has_many :reviews, :inverse_of => 'game'
  has_many :plugins, :inverse_of => 'game'

  def update_lazy_counters
    self.mods_count = Mod.where(game_id: self.id).count
    self.nexus_infos_count = NexusInfo.where(game_id: self.id).count
    self.lover_infos_count = LoverInfo.where(game_id: self.id).count
    self.mod_lists_count = ModList.where(game_id: self.id).count
    self.config_files_count = ConfigFile.where(game_id: self.id).count
    self.asset_files_count = AssetFile.where(game_id: self.id).count
    self.compatibility_notes_count = CompatibilityNote.where(game_id: self.id).count
    self.incorrect_notes_count = IncorrectNote.where(game_id: self.id).count
    self.install_order_notes_count = InstallOrderNote.where(game_id: self.id).count
    self.load_order_notes_count = LoadOrderNote.where(game_id: self.id).count
    self.reviews_count = Review.where(game_id: self.id).count
    self.plugins_count = Plugin.where(game_id: self.id).count
  end
end
