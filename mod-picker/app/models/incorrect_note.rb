class IncorrectNote < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :game, :inverse_of => 'incorrect_notes'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'incorrect_notes'

  has_many :agreement_marks, :inverse_of => 'incorrect_note'
  has_many :comments, :as => 'commentable'
  
  belongs_to :correctable, :polymorphic => true
  has_one :base_report, :as => 'reportable'

  # Validations
  validates :text_body, length: { in: 64..16384 }
  validates :correctable_id, :correctable_type, presence: true

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.correctable.update_counter(:incorrect_notes_count, 1)
      self.user.update_counter(:incorrect_notes_count, 1)
    end

    def decrement_counters
      self.correctable.update_counter(:incorrect_notes_count, -1)
      self.user.update_counter(:incorrect_notes_count, -1)
    end 
end
