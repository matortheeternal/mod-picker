class Cell < ActiveRecord::Base
  include BetterJson

  belongs_to :game
  belongs_to :worldspace
end
