class ReputationLink < ActiveRecord::Base
  self.primary_keys = :from_rep_id, :to_rep_id

  belongs_to :target_reputation, :class_name => 'UserReputation', :inverse_of => 'received_reputation'
  belongs_to :source_reputation, :class_name => 'UserReputation', :inverse_of => 'given_reputation'

  # Validations
  validates :from_rep_id, :to_rep_id, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def decrement_counters
      self.from_rep.update_counter(:rep_to_count, -1)
      self.to_rep.update_counter(:rep_from_count, -1)
    end

    def increment_counters
      self.from_rep.update_counter(:rep_to_count, 1)
      self.to_rep.update_counter(:rep_from_count, 1)
    end
end
