class InstallationNote < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'installation_notes'
  belongs_to :mod_version, :inverse_of => 'installation_notes'

  has_many :compatibility_notes, :inverse_of => 'installation_note'

  has_many :mod_lists, :through => 'mod_list_installation_notes', :inverse_of => 'installation_notes'
  has_many :mod_list_installation_notes, :inverse_of => 'installation_note'

  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'
end
