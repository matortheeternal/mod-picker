class HelpfulMark < EnhancedRecord::Base
  include Filterable
  
  self.primary_keys = :submitted_by, :helpfulable_id, :helpfulable_type

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :helpfulable, :polymorphic => true
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'helpful_marks'

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
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def decrement_counters
      if self.helpful
        self.helpfulable.update_counter(:helpful_count, -1)
      else
        self.helpfulable.update_counter(:not_helpful_count, -1)
      end
    end

    def increment_counters
      if self.helpful
        self.helpfulable.update_counter(:helpful_count, 1)
      else
        self.helpfulable.update_counter(:not_helpful_count, 1)
      end
    end
end
