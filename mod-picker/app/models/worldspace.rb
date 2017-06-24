class Worldspace < ActiveRecord::Base
  include BetterJson

  belongs_to :game
  belongs_to :plugin
end
