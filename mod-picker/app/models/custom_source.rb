class CustomSource < ActiveRecord::Base
  belongs_to :mod, :inverse_of => :custom_sources

  # Validations
  validates :mod_id, :url, presence: true
  validates :label, length: { in: 4..255 }
  validates :url, length: { in: 12..255 }
end
