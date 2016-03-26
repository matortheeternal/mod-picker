class Comment < ActiveRecord::Base
  include Filterable

  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'
  belongs_to :commentable, :polymorphic => true

  validates :submitted_by, :submitted, :commentable_type, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList"]
  # validates :commentable_type, inclusion: ["profile_comment"]
  validate :validate_text_body_length

  after_create :create_associations
  after_initialize :init

  def init
    self.submitted  ||= DateTime.now.to_date
    self.hidden     ||= false
  end
  
  def create_associations
    # TODO: Create associations for 
    # commentable_id
    # submitted_by(?)
  end

  def validate_text_body_length
    case self.commentable_type
      when "User"
        errors.add(:text_body, "length must be between 1 and 100") if !self.text_body.length.between?(1, 100) 
      when "ModList"
        errors.add(:text_body, "length must be between 1 and 200") if !self.text_body.length.between?(1, 200)
    end
  end
end
