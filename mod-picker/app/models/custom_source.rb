class CustomSource < ActiveRecord::Base
  belongs_to :mod, :inverse_of => :custom_sources

  # VALIDATIONS
  validates :label, :url, presence: true
  validates :label, length: { in: 4..255 }
  validates :url, length: { in: 12..255 }
end
