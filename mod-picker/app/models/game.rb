class Game < ActiveRecord::Base
  has_many :mods, :inverse_of => 'game'
  has_many :nexus_infos, :inverse_of => 'game'
  has_many :mod_lists, :inverse_of => 'game'
  has_many :config_files, :inverse_of => 'game'
  has_many :asset_files, :inverse_of => 'game'
  has_many :compatibility_notes, :inverse_of => 'game'
  has_many :incorrect_notes, :inverse_of => 'game'
  has_many :install_order_notes, :inverse_of => 'game'
  has_many :load_order_notes, :inverse_of => 'game'
  has_many :reviews, :inverse_of => 'game'
  has_many :plugins, :inverse_of => 'game'
end
