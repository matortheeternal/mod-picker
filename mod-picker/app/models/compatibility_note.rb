class CompatibilityNote < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'

  belongs_to :installation_note, :inverse_of => 'compatibility_notes'
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_notes'

  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'

  has_many :mod_version_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_versions, :through => 'mod_version_compatibility_notes', :inverse_of => 'compatibility_notes'

  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'


  def as_json(options={})
    super(:include => {
        :mod_version_compatibility_notes => {
            :except => [:compatibility_note_id, :mod_version_id],
            :include => {
                :mod_version => {
                    :except => [:id, :released, :obsolete, :dangerous]
                }
            }
        }
    })
  end
end
