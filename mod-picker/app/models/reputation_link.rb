class ReputationLink < ActiveRecord::Base
  include Trackable

  # ATTRIBUTES
  self.primary_keys = :from_rep_id, :to_rep_id

  # EVENT TRACKING
  track :added, :removed

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :target_user, to: [:added]

  # ASSOCIATIONS
  belongs_to :target_reputation, :class_name => 'UserReputation', :foreign_key => 'to_rep_id', :inverse_of => 'incoming_reputation_links'
  belongs_to :source_reputation, :class_name => 'UserReputation', :foreign_key => 'from_rep_id', :inverse_of => 'outgoing_reputation_links'
  has_one :target_user, :class_name => 'User', :through => :target_reputation, :source => 'user'
  has_one :source_user, :class_name => 'User', :through => :source_reputation, :source => 'user'

  # VALIDATIONS
  validates :from_rep_id, :to_rep_id, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def removed_by
    source_user.id
  end

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :target_user => { :only => [:id, :username] },
            :source_user => { :only => [:id, :username] }
        }
    }
  end

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
