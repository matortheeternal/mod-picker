class DummyMaster < ActiveRecord::Base
  include BetterJson

  belongs_to :plugin, :inverse_of => 'dummy_masters'

  # VALIDATIONS
  validates :plugin_id, :index, :filename, presence: true
  validates :filename, length: { in: 4..128 }
end
