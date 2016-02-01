class CompatibilityNote < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'

  belongs_to :installation_note, :inverse_of => 'compatibility_notes'
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_notes'

  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'

  has_many :mod_version_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_versions, :through => 'mod_version_compatibility_notes', :inverse_of => 'compatibility_notes'

  has_many :helpful_marks, :as => 'helpfulable'
end
