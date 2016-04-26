class WorkshopInfo < ActiveRecord::Base
  belongs_to :mod

  # Validations
  validates :mod_id, presence: true
end
