class PremiumSubscription < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  user_scope :user

  # UNIQUE SCOPES
  scope :active, -> { where("end > ?", DateTime.now) }

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'premium_subscriptions'
end
