class PremiumSubscription < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # ATTRIBUTES
  enum subscription_type: [:free, :one_month, :three_months, :six_months, :one_year]

  # SCOPES
  user_scope :user

  # UNIQUE SCOPES
  scope :active, -> { where("end > ?", DateTime.now) }

  # ASSOCIATIONS
  belongs_to :user, :inverse_of => 'premium_subscriptions'
end
