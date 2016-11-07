class CuratorRequest < ActiveRecord::Base
  include RecordEnhancements, BetterJson, CounterCache, ScopeHelpers

  # ATTRIBUTES
  enum state: [:open, :approved, :denied]

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'curator_requests'
  belongs_to :mod, :inverse_of => 'curator_requests'

  # VALIDATIONS
  validates :user_id, :mod_id, :message, presence: true
end
