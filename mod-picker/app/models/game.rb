class Game < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
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
  has_many :related_mod_notes, :inverse_of => 'game'
  has_many :corrections, :inverse_of => 'game'
  has_many :install_order_notes, :inverse_of => 'game'
  has_many :load_order_notes, :inverse_of => 'game'
  has_many :reviews, :inverse_of => 'game'
  has_many :plugins, :inverse_of => 'game'
  has_many :help_pages, :inverse_of => 'game'

  # COUNTER CACHE
  counter_cache :mods, :nexus_infos, :lover_infos, :workshop_infos, :mod_lists, :config_files, :asset_files, :compatibility_notes, :corrections, :install_order_notes, :load_order_notes, :related_mod_notes, :reviews, :plugins, :help_pages

  # VALIDATIONS
  validates :display_name, :long_name, :abbr_name, presence: true

  # gets the display image path via the game's display_name if one is present
  def display_image
    png_path = File.join(Rails.public_path, "games/#{id}.png")
    jpg_path = File.join(Rails.public_path, "games/#{id}.jpg")

    if File.exists?(png_path)
      "/games/#{id}.png"
    elsif File.exists?(jpg_path)
      "/games/#{id}.jpg"
    else
      '/games/Default.png'
    end 
  end

  def update_lazy_counters!
    reset_counters!(:mods, :nexus_infos, :lover_infos, :workshop_infos, :mod_lists, :config_files, :asset_files, :compatibility_notes, :corrections, :install_order_notes, :load_order_notes, :related_mod_notes, :reviews, :plugins, :help_pages)
  end

  def url
    self.display_name.parameterize.gsub("-", "")
  end

  def help_url
    self.display_name.parameterize.underscore
  end
end
