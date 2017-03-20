class TagGroupTag < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
  belongs_to :tag_group
  belongs_to :tag
  has_many :mod_tags, -> (object) { joins(:mod).where("mods.primary_category_id in (:ids) OR mods.secondary_category_id in (:ids)", ids: object.tag_group.category_ids) }, through: "tag"

  # COUNTER CACHE
  counter_cache :mod_tags, column: 'mod_tags_count'

  # VALIDATIONS
  validates :tag_group_id, :tag_id, :index, presence: true

  # CALLBACKS
  after_create :reset_mod_tags_counter

  def reset_mod_tags_counter
    reset_counter!(:mod_tags)
  end
end
