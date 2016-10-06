class Comment < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable, ScopeHelpers, Trackable, BetterJson

  # ATTRIBUTES
  self.per_page = 50

  # EVENT TRACKING
  track :added, :hidden

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :commentable_user, to: [:added]
  subscribe :submitter, to: [:hidden, :unhidden]
  subscribe :parent_submitter, to: [:added]

  # SCOPES
  include_scope :hidden
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  polymorphic_scope :commentable
  range_scope :children_count, :alias => 'replies'
  date_scope :submitted, :edited

  # UNIQUE SCOPES
  scope :include_replies, -> (bool) { where(parent_id: nil) if !bool }

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'parent', :dependent => :destroy

  # VALIDATIONS
  validates :submitted_by, :commentable_type, :commentable_id, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList", "Correction", "Article", "HelpPage"]
  validates :text_body, length: {in: 2..8192}
  validate :nesting

  # CALLBACKS
  before_save :set_adult, :set_dates
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  def nesting
    parent_id.nil? || parent.parent_id.nil?
  end

  def parent_submitter
    parent_id.present? && parent.submitter
  end

  def commentable_link
    if commentable_type == "Correction"
      if commentable.correctable_type == "Mod"
        "#/mods/" + commentable.correctable_id.to_s + "/appeals/" + commentable_id.to_s
      elsif commentable.correctable_type == "CompatibilityNote"
        "#/mods/compatibility/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "InstallOrderNote"
        "#/mods/install-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "LoadOrderNote"
        "#/mods/load-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      end
    elsif commentable_type == "ModList"
      "#/mod-list/" + commentable_id.to_s
    elsif commentable_type == "User"
      "#/user/" + commentable_id.to_s
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

  def self.sortable_columns
    {
        :except => [:parent_id, :submitted_by, :commentable_id, :text_body],
        :include => {
            :submitter => {
                :only => [:username],
                :include => {
                    :reputation => {
                        :only => [:overall]
                    }
                }
            }
        }
    }
  end

  # Private methods
  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def set_adult
      if commentable.respond_to?(:has_adult_content)
        self.has_adult_content = commentable.has_adult_content
      end
      true
    end

    def increment_counter_caches
      submitter.update_counter(:submitted_comments_count, 1)
      commentable.update_counter(:comments_count, 1)
      if parent_id.present?
        parent.update_counter(:children_count, 1)
      end
    end

    def decrement_counter_caches
      submitter.update_counter(:submitted_comments_count, -1)
      commentable.update_counter(:comments_count, -1)
      if parent_id.present?
        parent.update_counter(:children_count, -1)
      end
    end

end
