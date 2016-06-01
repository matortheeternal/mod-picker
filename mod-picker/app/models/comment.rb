class Comment < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  has_one :base_report, :as => 'reportable'

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'

  # Validations
  validates :submitted_by, :commentable_type, :commentable_id, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList"]
  validates :text_body, length: {in: 1..8192}

  # Callbacks
  after_initialize :init
  before_save :set_dates
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private methods
  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def init
      if self.hidden.nil?
        self.hidden = false
      end
    end


    def increment_counter_caches
      self.user.update_counter(:submitted_comments_count, 1)
      self.commentable.update_counter(:comments_count, 1)
      if self.parent_id.present?
        self.parent.update_counter(:children_count, 1)
      end
    end

    def decrement_counter_caches
      self.user.update_counter(:submitted_comments_count, -1)
      self.commentable.update_counter(:comments_count, -1)
      if self.parent_id.present?
        self.parent.update_counter(:children_count, -1)
      end
    end

end
