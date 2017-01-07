class ApiToken < ActiveRecord::Base
  include RecordEnhancements, BetterJson, Dateable

  # DATE COLUMNS
  date_column :created

  # ASSOCIATIONS
  belongs_to :user, inverse_of: 'api_tokens'

  # VALIDATIONS
  validates :name, presence: true
  validates :name, length: { maximum: 64 }

  # CALLBACKS
  after_initialize :generate_api_key

  def generate_api_key
    api_key = SecureRandom.urlsafe_base64
    generate_api_key if ApiToken.where(api_key: api_key).exists?
  end

  def increment_requests!
    requests_count += 1
    update_columns(requests_count: requests_count)
  end

  def expire
    return if expired
    expired = true
    date_expired = DateTime.now
  end
end