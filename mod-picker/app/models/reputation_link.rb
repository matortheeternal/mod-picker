class ReputationLink < ActiveRecord::Base
  include Trackable, BetterJson, CounterCache

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :target_user, to: [:added]

  # ASSOCIATIONS
  belongs_to :target_reputation, :class_name => 'UserReputation', :foreign_key => 'to_rep_id', :inverse_of => 'incoming_reputation_links'
  belongs_to :source_reputation, :class_name => 'UserReputation', :foreign_key => 'from_rep_id', :inverse_of => 'outgoing_reputation_links'
  has_one :target_user, :class_name => 'User', :through => :target_reputation, :source => 'user'
  has_one :source_user, :class_name => 'User', :through => :source_reputation, :source => 'user'

  # COUNTER CACHE
  counter_cache_on :source_reputation, column: 'rep_to_count'
  counter_cache_on :target_reputation, column: 'rep_from_count'

  # VALIDATIONS
  validates :from_rep_id, :to_rep_id, presence: true
end
