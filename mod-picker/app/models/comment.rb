class Comment < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Reportable, ScopeHelpers, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  self.per_page = 50

  # DATE COLUMNS
  date_column :submitted, :edited

  # EVENT TRACKING
  track :added, :hidden

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :commentable_user, to: [:added]
  subscribe :submitter, to: [:hidden, :unhidden]
  subscribe :parent_submitter, to: [:added]

  # SCOPES
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  include_scope :hidden
  include_scope :parent_id, value: nil, alias: 'include_replies'
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  polymorphic_scope :commentable
  range_scope :children_count, :alias => 'replies'
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'parent', :dependent => :destroy

  # COUNTER CACHE
  counter_cache :children, conditional: { hidden: false }
  counter_cache_on :submitter, column: 'submitted_comments_count', conditional: { hidden: false }
  counter_cache_on :commentable, conditional: { hidden: false }
  counter_cache_on :parent, column: 'children_count', conditional: { hidden: false }

  # VALIDATIONS
  validates :submitted_by, :commentable_type, :commentable_id, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList", "Correction", "Article", "HelpPage"]
  validates :text_body, length: {in: 2..8192}
  validate :nesting

  # CALLBACKS
  before_save :set_adult

  def nesting
    parent_id.nil? || parent.parent_id.nil?
  end

  def parent_submitter
    parent_id.present? && parent.submitter
  end

  def context_link
    if commentable_type == "Correction"
      if commentable.correctable_type == "Mod"
        "mods/" + commentable.correctable_id.to_s + "/appeals/" + commentable_id.to_s
      elsif commentable.correctable_type == "CompatibilityNote"
        "mods/compatibility/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "InstallOrderNote"
        "mods/install-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "LoadOrderNote"
        "mods/load-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      end
    elsif commentable_type == "ModList"
      "mod-lists/" + commentable_id.to_s + "/comments"
    elsif commentable_type == "Article"
      "articles/" + commentable_id.to_s
    elsif commentable_type == "HelpPage"
      "/help/" + commentable.url
    elsif commentable_type == "User"
      "user/" + commentable_id.to_s + "/social"
    end
  end

  def commentable_user
    case commentable_type
      when "Correction", "ModList", "Article"
        commentable.submitter
      when "User"
        commentable
      else
        nil
    end
  end

  # Private methods
  private
    def set_adult
      if commentable.respond_to?(:has_adult_content)
        self.has_adult_content = commentable.has_adult_content
      end
      true
    end
end
