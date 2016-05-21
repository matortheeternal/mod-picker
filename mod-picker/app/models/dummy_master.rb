class DummyMaster < EnhancedRecord::Base
  belongs_to :plugin, :inverse_of => 'dummy_masters'

  # Validations
  validates :filename, :plugin_id, :index, presence: true
  validates :filename, length: { maximum: 64 }
end
