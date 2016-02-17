class Comment < ActiveRecord::Base
  include Filterable

  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
end
