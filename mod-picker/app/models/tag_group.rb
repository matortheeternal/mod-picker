class TagGroup < ActiveRecord::Base
  include RecordEnhancements, CounterCache, ScopeHelpers, BetterJson

  # ATTRIBUTES
  attr_accessor :category_name, :tag_names

  # SCOPES
  game_scope

  scope :category, -> (id) {
    category_ids = [id] + Category.where(parent_id: id).ids
    where(category_id: category_ids)
  }

  # ASSOCIATIONS
  belongs_to :game
  belongs_to :category
  has_many :tag_group_tags, :dependent => :destroy

  # COUNTER CACHE
  counter_cache :tag_group_tags, column: 'tags_count'

  # VALIDATIONS
  validates :game_id, :category_id, :name, presence: true
  validates :name, length: {in: 2..64}

  # CALLBACKS
  after_create :link_tags

  def next_index
    tags = tag_group_tags.select { |tag| tag.id.present? }
    tags.empty? ? 0 : tags.max_by(&:index)
  end

  def add_tag(tag, _alias=nil)
    tag_group_tags.create(tag_id: tag.id, index: next_index, alias: _alias)
  end

  private
  def link_tags
    if @tag_names.present?
      @tag_names.each do |tag_name|
        tag = Tag.where(game_id: game_id, text: tag_name).first || Tag.create!(game_id: game_id, text: tag_name, submitted_by: 1)
        add_tag(tag)
      end
    end
  end
end
