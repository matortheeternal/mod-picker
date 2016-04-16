class CompatibilityNote < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }
  scope :type, -> (array) { where(compatibility_type: array) }

  # FIXME: change this back to status: once the schema has been updated.
  enum compatibility_type: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'

  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_note_plugins'
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id', :inverse_of => 'compatibility_note_mods'

  # mod versions this compatibility note is associated with
  has_many :mod_version_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_versions, :through => 'mod_version_compatibility_notes', :inverse_of => 'compatibility_notes'

  # mod lists this compatibility note appears on
  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'

  # community feedback on this compatibility note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'

  # old versions of this compatibility note
  has_many :compatibility_note_history_entries, :inverse_of => 'compatibility_note'

  # validations
  validates :submitted_by, presence: true
  validates :text_body, length: { in: 64..16384 }                                            


  def init
    self.submitted ||= DateTime.now
  end                 

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
