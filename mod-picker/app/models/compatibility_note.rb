class CompatibilityNote < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }
  scope :type, -> (array) { where(compatibility_type: array) }

  # FIXME: change this back to status: once the schema has been updated.
  enum compatibility_type: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  belongs_to :game, :inverse_of => 'compatibility_notes'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_notes'

  # associated mods
  belongs_to :first_mod, :class_name => 'Mod', :foreign_key => 'first_mod_id'
  belongs_to :second_mod, :class_name => 'Mod', :foreign_key => 'second_mod_id'

  # associated compatibility plugin/compatibilty mod for automatic resolution purposes
  belongs_to :compatibility_plugin, :class_name => 'Plugin', :foreign_key => 'compatibility_plugin_id', :inverse_of => 'compatibility_note_plugins'
  belongs_to :compatibility_mod, :class_name => 'Mod', :foreign_key => 'compatibility_mod_id', :inverse_of => 'compatibility_note_mods'

  # mod lists this compatibility note appears on
  has_many :mod_list_compatibility_notes, :inverse_of => 'compatibility_note'
  has_many :mod_lists, :through => 'mod_list_compatibility_notes', :inverse_of => 'compatibility_notes'

  # community feedback on this compatibility note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'
  has_one :base_report, :as => 'reportable'

  # old versions of this compatibility note
  has_many :compatibility_note_history_entries, :inverse_of => 'compatibility_note'

  # validations
  validates :submitted_by, presence: true
  validates :text_body, length: { in: 64..16384 }                                            


  def init
    self.submitted ||= DateTime.now
  end

  def mods
    [first_mod, second_mod]
  end

  def as_json(options={})
    if options == {}
      super({
          :except => [:submitted_by],
          :include => {
              :user => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              }
          },
          :methods => :mods
      })
    else
      super(options)
    end
  end
end
