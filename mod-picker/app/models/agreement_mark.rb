class AgreementMark < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'agreement_marks'
  belongs_to :incorrect_note, :inverse_of => 'agreement_marks'

  validates :incorrect_note_id, :submitted_by, presence: true
  validates :agree, inclusion: [true, false]
end
