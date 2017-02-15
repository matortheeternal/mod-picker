class LicenseOption < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
  belongs_to :license

  # VALIDATIONS
  validates :name, presence: true
end
