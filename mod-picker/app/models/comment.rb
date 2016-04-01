class Comment < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'

  # validation
  validates :submitted_by, :submitted, :commentable_type, :commentable_id, presence: true
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
end
