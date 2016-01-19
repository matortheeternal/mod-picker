class InstallationNote < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'installation_notes'
  belongs_to :mod_version, :inverse_of => 'installation_notes'
  has_many :compatibility_notes, :inverse_of => 'installation_note'
end
