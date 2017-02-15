class LicenseOption < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
  belongs_to :license

  has_many :mod_licenses

  # VALIDATIONS
  validates :name, presence: true
end
