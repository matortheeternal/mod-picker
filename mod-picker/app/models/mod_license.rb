class ModLicense < ActiveRecord::Base
  include RecordEnhancements, CounterCache, BetterJson

  # ATTRIBUTES
  enum target: [:code, :assets, :materials]

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :license
  belongs_to :license_option

  # VALIDATIONS
  validates :target, presence: true
  validates :text_body, length: { maximum: 65536 }

  # CALLBACKS
  before_create :inherit_terms

  def term_keys
    %w(credit commercial redistribution modification private_use include)
  end

  def inherit_terms
    return if license_id.nil?
    term_keys.each { |term| public_send("#{term}=", license.public_send(term)) }
  end
end
