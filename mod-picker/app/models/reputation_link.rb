class ReputationLink < ActiveRecord::Base
  self.primary_keys = :from_rep_id, :to_rep_id

  belongs_to :target_reputation, :class_name => 'UserReputation', :foreign_key => 'to_rep_id', :inverse_of => 'incoming_reputation_links'
  belongs_to :source_reputation, :class_name => 'UserReputation', :foreign_key => 'from_rep_id', :inverse_of => 'outgoing_reputation_links'

  # VALIDATIONS
  validates :from_rep_id, :to_rep_id, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def decrement_counters
      self.source_reputation.update_counter(:rep_to_count, -1)
      self.target_reputation.update_counter(:rep_from_count, -1)
    end

    def increment_counters
      self.source_reputation.update_counter(:rep_to_count, 1)
      self.target_reputation.update_counter(:rep_from_count, 1)
    end
end
