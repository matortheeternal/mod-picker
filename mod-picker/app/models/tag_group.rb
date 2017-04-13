class TagGroup < ActiveRecord::Base
  include RecordEnhancements, CounterCache, ScopeHelpers, BetterJson

  # ATTRIBUTES
  attr_accessor :category_name, :tag_names

  # SCOPES
  game_scope

  # ASSOCIATIONS
  belongs_to :game
  belongs_to :category
  has_many :tag_group_tags, -> { order(:index) }, :dependent => :destroy

  # COUNTER CACHE
  counter_cache :tag_group_tags, column: 'tags_count'

  # VALIDATIONS
  validates :game_id, :category_id, :name, presence: true
  validates :name, length: {in: 2..64}

  # CALLBACKS
  after_create :link_tags

  def alphabetize
    tag_group_tags.joins(:tag).order(tag: "text").each_with_index do |t,i|
      t.update(index: i)
    end
  end

  def set_indexes
    tag_group_tags.each_with_index do |t,i|
      t.update(index: i)
    end
  end

  def next_index
    tag_group_tags.empty? ? 0 : tag_group_tags.max_by(&:index)
  end

  def category_ids
    category.parent_id.nil? ? category.sub_categories.ids + [category_id] : category_id
  end

  def add_tag(tag, _alias=nil)
    TagGroupTag.create(tag_group_id: id, tag_id: tag.id, index: next_index, alias: _alias)
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
