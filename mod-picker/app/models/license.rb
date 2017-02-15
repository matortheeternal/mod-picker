class License < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
  has_many :license_options

  accepts_nested_attributes_for :license_options

  # VALIDATIONS
  validates :name, :clauses, :license_type, :credit, :commercial, :redistribution, :modification, :private_use, :include, presence: true
end
