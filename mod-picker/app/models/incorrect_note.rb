class IncorrectNote < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'incorrect_notes'
  has_many :agreement_marks, :inverse_of => 'incorrect_note'
  belongs_to :correctable, :polymorphic => true
end
