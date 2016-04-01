class LoadOrderNote < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'

  # plugins associatied with this load order note
  belongs_to :load_first_plugin, :foreign_key => 'load_first', :class_name => 'Plugin', :inverse_of => 'load_before_notes'
  belongs_to :load_second_plugin, :foreign_key => 'load_second', :class_name => 'Plugin', :inverse_of => 'load_after_notes'

  # mod versions this load order note is associated with
  has_many :mod_list_installation_notes, :inverse_of => 'load_order_note'
  has_many :mod_lists, :through => 'mod_list_load_order_notes', :inverse_of => 'load_order_notes'

  # mod lists this load order note appears on
  has_many :mod_version_load_order_notes, :inverse_of => 'load_order_note'
  has_many :mod_versions, :through => 'mod_version_load_order_notes', :inverse_of => 'load_order_notes'

  # community feedback on this load order note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'


  def as_json(options={})
    super(:include => {
        :mod_version_load_order_notes => {
            :except => [:load_order_note_id, :mod_version_id],
            :include => {
                :mod_version => {
                    :except => [:id, :released, :obsolete, :dangerous]
                }
            }
        }
    })
  end
end
