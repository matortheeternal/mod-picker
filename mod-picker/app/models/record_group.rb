class RecordGroup < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'record_groups'
end
