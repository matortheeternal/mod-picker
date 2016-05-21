class Game < ActiveRecord::Base
  has_many :mods, :inverse_of => 'game'
  has_many :nexus_infos, :inverse_of => 'game'
  has_many :lover_infos, :inverse_of => 'game'
  has_many :workshop_infos, :inverse_of => 'game'
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
    self.mods_count = self.mods.count
    self.nexus_infos_count = self.nexus_infos.count
    self.lover_infos_count = self.lover_infos.count
    self.workshop_infos_count = self.workshop_infos.count
    self.mod_lists_count = self.mod_lists.count
    self.config_files_count = self.config_files.count
    self.asset_files_count = self.asset_files.count
    self.compatibility_notes_count = self.compatibility_notes.count
    #self.incorrect_notes_count = self.incorrect_notes.count
    self.install_order_notes_count = self.install_order_notes.count
    self.load_order_notes_count = self.load_order_notes.count
    self.reviews_count = self.reviews.count
    self.plugins_count = self.plugins.count
  end
end
