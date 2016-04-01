class InstallOrderNote < ActiveRecord::Base
  include Filterable

  after_create :update_counter_cache
  after_update :update_counter_cache
  after_initialize :init

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'

  # mods associatied with this install order note
  belongs_to :install_first_mod, :foreign_key => 'install_first', :class_name => 'Mod', :inverse_of => 'install_before_notes'
  belongs_to :install_second_mod, :foreign_key => 'install_second', :class_name => 'Mod', :inverse_of => 'install_after_notes'

  # mod versions this install order note is associated with
  has_many :mod_list_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_lists, :through => 'mod_list_install_order_notes', :inverse_of => 'install_order_notes'

  # mod lists this install order note appears on
  has_many :mod_version_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_versions, :through => 'mod_version_install_order_notes', :inverse_of => 'install_order_notes'

  # community feedback on this install order note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'

  # validations
  validates :install_first, :install_second, presence: true
  validates :text_body, length: { in: 64..16384 }
  
  
  # initialize variables if empty/nil
  def init
    self.submitted ||= DateTime.now
  end

  # update mod counter cache columns
  def update_counter_cache
    self.install_first_mod.update_install_order_notes_count
    self.install_second_mod.update_install_order_notes_count
  end

  def as_json(options={})
    super(:include => {
        :mod_version_install_order_notes => {
            :except => [:install_order_note_id, :mod_version_id],
            :include => {
                :mod_version => {
                    :except => [:id, :released, :obsolete, :dangerous]
                }
            }
        }
    })
  end
end
