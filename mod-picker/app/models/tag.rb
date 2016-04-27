class Tag < ActiveRecord::Base
  include Filterable

  scope :game, -> (game) { where(game_id: game) }

  has_many :mod_tags, :inverse_of => 'tag'
  has_many :mods, :through => 'mod_tags', :inverse_of => 'tags'

  has_many :mod_list_tags, :inverse_of => 'tag'
  has_many :mod_lists, :through => 'mod_list_tags', :inverse_of => 'tags'

  has_one :base_report, :as => 'reportable'

  # Validations
  validates :text, :game_id, :submitted_by, presence: true
  validates :text, length: {in: 2..32}
  validates :disabled, inclusion: [true, false]
end
