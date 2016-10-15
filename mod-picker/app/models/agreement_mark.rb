class AgreementMark < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  self.primary_keys = :correction_id, :submitted_by

  # SCOPES
  ids_scope :correction_id
  value_scope :submitted_by, :alias => 'submitter'

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'agreement_marks'
  belongs_to :correction, :inverse_of => 'agreement_marks'

  # VALIDATIONS
  validates :correction_id, :submitted_by, presence: true
  validates :agree, inclusion: [true, false]

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def decrement_counters
      submitter.update_counter(:agreement_marks_count, -1)
      if agree
        correction.update_counter(:agree_count, -1)
      else
        correction.update_counter(:disagree_count, -1)
      end
    end

    def increment_counters
      submitter.update_counter(:agreement_marks_count, 1)
      if agree
        correction.update_counter(:agree_count, 1)
      else
        correction.update_counter(:disagree_count, 1)
      end
    end
end
