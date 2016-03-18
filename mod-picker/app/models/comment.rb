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
  validates_inclusion_of :hidden, in: [true, false]


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
end
