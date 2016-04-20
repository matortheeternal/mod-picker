class Report < ActiveRecord::Base
  belongs_to :base_report, :inverse_of => 'reports'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reports'
end
