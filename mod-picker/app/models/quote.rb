class Quote < ActiveRecord::Base
  belongs_to :game

  # VALIDATIONS
  validates :game_id, :text, :label, presence: true
  validates :text, length: {maximum: 255}
  validates :label, length: {maximum: 32}
end
