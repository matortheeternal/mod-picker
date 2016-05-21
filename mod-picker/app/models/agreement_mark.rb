class AgreementMark < ActiveRecord::Base
  self.primary_keys = :incorrect_note_id, :submitted_by

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'agreement_marks'
  belongs_to :incorrect_note, :inverse_of => 'agreement_marks'

  # Validations
  validates :incorrect_note_id, :submitted_by, presence: true
  validates :agree, inclusion: [true, false]

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def decrement_counters
      if self.agree
        self.incorrect_note.update_counter(:agree_count, -1)
      else
        self.incorrect_note.update_counter(:disagree_count, -1)
      end
    end

    def increment_counters
      if self.agree
        self.incorrect_note.update_counter(:agree_count, 1)
      else
        self.incorrect_note.update_counter(:disagree_count, 1)
      end
    end
end
