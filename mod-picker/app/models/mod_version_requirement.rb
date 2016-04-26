class ModVersionRequirement < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :required_id

  belongs_to :mod_version, :inverse_of => 'requires'
  belongs_to :required_mod_version, :class_name => 'ModVersion', :inverse_of => 'required_by', :foreign_key => 'required_id'

  # Validations
  validates :mod_version_id, :required_id, presence: true
end
