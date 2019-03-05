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

  # CALLBACKS
  before_create :set_dates

  def get_start_date
    last_subscription = user.premium_subscriptions.active.last
    return DateTime.now if last_subscription.nil?
    last_subscription.end
  end

  def get_end_date
    {
      free: 1.month.from_now,
      one_month: 1.month.from_now,
      three_months: 3.months.from_now,
      six_months: 6.months.from_now,
      one_year: 1.year.from_now
    }[self.subscription_type.to_sym]
  end

  def set_dates
    self.purchased = DateTime.now
    self.start = get_start_date
    self.end = get_end_date
  end

  def is_active
    self.end > DateTime.now
  end
end
