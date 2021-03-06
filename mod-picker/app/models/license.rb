class License < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ASSOCIATIONS
  has_many :license_options
  has_many :mod_licenses

  accepts_nested_attributes_for :license_options

  # VALIDATIONS
  validates :name, :clauses, :license_type, :credit, :commercial, :redistribution, :modification, :private_use, :include, presence: true

  def terms
    {
        credit: credit,
        commercial: commercial,
        redistribution: redistribution,
        modification: modification,
        private_use: private_use,
        include: include
    }
  end
end
