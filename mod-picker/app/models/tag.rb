class Tag < ActiveRecord::Base
  include Filterable, RecordEnhancements, Reportable

  scope :game, -> (game) { where(game_id: game) }

  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitted_by, :inverse_of => 'tags'

  has_many :mod_tags, :inverse_of => 'tag'
  has_many :mods, :through => 'mod_tags', :inverse_of => 'tags'

  has_many :mod_list_tags, :inverse_of => 'tag'
  has_many :mod_lists, :through => 'mod_list_tags', :inverse_of => 'tags'

  # VALIDATIONS
  validates :game_id, :submitted_by, :text, presence: true
  validates :text, length: {in: 2..32}
  validates :hidden, inclusion: [true, false]

  # CALLBACKS
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private methods
  private
    def increment_counter_caches
      self.submitter.update_counter(:tags_count, 1)
    end

    def decrement_counter_caches
      self.submitter.update_counter(:tags_count, -1)
    end
end
