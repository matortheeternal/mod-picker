class Tag < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :game, -> (game) { where(game_id: game) }

  belongs_to :user, :foreign_key => :submitted_by, :inverse_of => 'tags'

  has_many :mod_tags, :inverse_of => 'tag'
  has_many :mods, :through => 'mod_tags', :inverse_of => 'tags'

  has_many :mod_list_tags, :inverse_of => 'tag'
  has_many :mod_lists, :through => 'mod_list_tags', :inverse_of => 'tags'

  has_one :base_report, :as => 'reportable'

  # Validations
  validates :text, :game_id, :submitted_by, presence: true
  validates :text, length: {in: 2..32}
  validates :hidden, inclusion: [true, false]

  def init
    self.mods_count ||= 0
  end

end
