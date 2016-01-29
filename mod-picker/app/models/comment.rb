class Comment < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_comment', :inverse_of => 'parent'
  has_one :commentable, :polymorphic => true
end
