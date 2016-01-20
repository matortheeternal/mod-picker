class Game < ActiveRecord::Base
  has_many :mods, :inverse_of => 'game'
  has_many :mod_lists, :inverse_of => 'game'
end
