class ReputationLink < ActiveRecord::Base
  self.primary_keys = :from_rep_id, :to_rep_id

  belongs_to :to_rep, :class_name => 'UserReputation', :inverse_of => 'from_links'
  belongs_to :from_rep, :class_name => 'UserReputation', :inverse_of => 'to_links'

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
