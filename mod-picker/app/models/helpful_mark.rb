class HelpfulMark < ActiveRecord::Base
  belongs_to :helpfulable, :polymorphic => true
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'helpful_marks'
end
