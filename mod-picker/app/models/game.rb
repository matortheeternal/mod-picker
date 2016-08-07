class Game < ActiveRecord::Base
  include RecordEnhancements
  
  # parent/child games
  belongs_to :parent_game, :class_name => 'Game', :foreign_key => 'parent_game_id', :inverse_of => 'children_games'
  has_many :children_games, :class_name => 'Game', :foreign_key => 'parent_game_id', :inverse_of => 'parent_game'

  # content associated with this game
  has_many :mods, :inverse_of => 'game'
  has_many :nexus_infos, :inverse_of => 'game'
  has_many :lover_infos, :inverse_of => 'game'
  has_many :workshop_infos, :inverse_of => 'game'
  has_many :mod_lists, :inverse_of => 'game'
  has_many :config_files, :inverse_of => 'game'
  has_many :asset_files, :inverse_of => 'game'
  has_many :compatibility_notes, :inverse_of => 'game'
  has_many :corrections, :inverse_of => 'game'
  has_many :install_order_notes, :inverse_of => 'game'
  has_many :load_order_notes, :inverse_of => 'game'
  has_many :reviews, :inverse_of => 'game'
  has_many :plugins, :inverse_of => 'game'
  has_many :help_pages, :inverse_of => 'game'

  # Validations
  validates :display_name, :long_name, :abbr_name, presence: true

  # gets the display image path via the game's display_name if one is present
  def display_image
    png_file_name = self.display_name.split("").join("_")
    jpg_file_name = self.display_name.split("").join("_")

    png_path = File.join(Rails.public_path, png_file_name)
    jpg_path = File.join(Rails.public_path, jpg_file_name)


    if File.exists?(png_path)
      "/games/#{id}.png"
    elsif File.exists?(jpg_path)
      "/games/#{id}.jpg"
    else
      '/games/Default.png'
    end 
  end

  def update_lazy_counters
    self.mods_count = self.mods.count
    self.nexus_infos_count = self.nexus_infos.count
    self.lover_infos_count = self.lover_infos.count
    self.workshop_infos_count = self.workshop_infos.count
    self.mod_lists_count = self.mod_lists.count
    self.config_files_count = self.config_files.count
    self.asset_files_count = self.asset_files.count
    self.compatibility_notes_count = self.compatibility_notes.count
    self.corrections_count = self.corrections.count
    self.install_order_notes_count = self.install_order_notes.count
    self.load_order_notes_count = self.load_order_notes.count
    self.reviews_count = self.reviews.count
    self.plugins_count = self.plugins.count
    self.help_pages_count = self.help_pages.count
  end

  def url_name
    self.display_name.parameterize.underscore
  end
end
