class AgreementMark < ActiveRecord::Base
  self.primary_keys = :correction_id, :submitted_by

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'agreement_marks'
  belongs_to :correction, :inverse_of => 'agreement_marks'

  # Validations
  validates :correction_id, :submitted_by, presence: true
  validates :agree, inclusion: [true, false]

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:correction_id, :agree]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def decrement_counters
      self.submitter.update_counter(:agreement_marks_count, -1)
      if self.agree
        self.correction.update_counter(:agree_count, -1)
      else
        self.correction.update_counter(:disagree_count, -1)
      end
    end

    def increment_counters
      self.submitter.update_counter(:agreement_marks_count, 1)
      if self.agree
        self.correction.update_counter(:agree_count, 1)
      else
        self.correction.update_counter(:disagree_count, 1)
      end
    end
end
