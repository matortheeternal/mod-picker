class ModListGroup < ActiveRecord::Base
  include BetterJson

  # ATTRIBUTES
  enum tab: [:tools, :mods, :plugins]
  enum color: [:red, :orange, :yellow, :green, :blue, :purple, :white, :gray, :brown, :black]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_groups'

  # VALIDATIONS
  validates :mod_list_id, :name, presence: true

  def self.base_json_format
    { :except => [:mod_list_id] }
  end
end
