class HelpfulMark < ActiveRecord::Base
  include Filterable
  
  self.primary_keys = :submitted_by, :helpfulable_id, :helpfulable_type

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :helpfulable, :polymorphic => true
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'helpful_marks'

  # Validation
  # :helpful's presence is not required because it will fail if :helpful == false
  validates :helpfulable_id, :helpfulable_type, presence: true

  validates :helpful, inclusion: {
    in: [true, false],
    message: "must be true or false"
  }

  validates :helpfulable_type, inclusion: {
    in: ["CompatibilityNote", "InstallOrderNote", "LoadOrderNote", "Review"],
    message: "Not a valid record that contains helpful marks"
  }

  # Callbacks
  before_save :set_dates
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def set_dates
      self.submitted = DateTime.now
    end

    def decrement_counters
      self.submitter.update_counter(:helpful_marks_count, -1)
      if self.helpful
        self.helpfulable.helpful_count -= 1
        self.helpfulable.compute_reputation
        self.helpfulable.update_columns(:helpful_count => self.helpfulable.helpful_count, :reputation => self.helpfulable.reputation)
      else
        self.helpfulable.not_helpful_count -= 1
        self.helpfulable.compute_reputation
        self.helpfulable.update_columns(:not_helpful_count => self.helpfulable.not_helpful_count, :reputation => self.helpfulable.reputation)
      end
    end

    def increment_counters
      self.submitter.update_counter(:helpful_marks_count, 1)
      if self.helpful
        self.helpfulable.helpful_count += 1
        self.helpfulable.compute_reputation
        self.helpfulable.update_columns(:helpful_count => self.helpfulable.helpful_count, :reputation => self.helpfulable.reputation)
      else
        self.helpfulable.not_helpful_count += 1
        self.helpfulable.compute_reputation
        self.helpfulable.update_columns(:not_helpful_count => self.helpfulable.not_helpful_count, :reputation => self.helpfulable.reputation)
      end
    end
end
