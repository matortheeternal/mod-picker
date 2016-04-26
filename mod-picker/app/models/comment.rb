class Comment < ActiveRecord::Base
  include Filterable

  after_initialize :init
  
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true
  
  has_one :base_report, :as => 'reportable'

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'

  # validation
  validates :submitted_by, :commentable_type, :commentable_id, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList"]

  validate :validate_text_body_length

  def init
    self.submitted  ||= Date.today
    self.hidden     ||= false
  end

  # validate text_body lengths, depending on commentable_type
  # TODO: refactor comment model method so it short circuits when blank
  def validate_text_body_length
    case self.commentable_type
      when "User"
        if text_body.blank?
          errors.add(:text_body, "body can't be empty")
        elsif !self.text_body.length.between?(1, 16384)
          errors.add(:text_body, "length must be less than 16384 characters")
        end
      when "ModList"
        if text_body.blank?
          errors.add(:text_body, "body can't be empty")
        elsif !self.text_body.length.between?(1, 4096)
          errors.add(:text_body, "length must be less than 4096 characters")
        end
    end
  end

  # Private methods
  private
    # counter caches
    def increment_counter_caches
      self.commentable.comments_count += 1
      self.commentable.save
    end

    def decrement_counter_caches
      self.commentable.comments_count -= 1
      self.commentable.save
    end

end
