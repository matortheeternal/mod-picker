class DummyMaster < ActiveRecord::Base
  belongs_to :plugin, :inverse_of => 'dummy_masters'
end
