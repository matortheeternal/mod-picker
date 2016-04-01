class InstallOrderNote < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'InstallOrderNote'

  has_many :mod_versions, :through => 'mod_version_install_order_notes'

  has_many :mod_lists, :through => 'mod_list_installation_notes', :inverse_of => 'InstallOrderNote'
  has_many :mod_list_install_order_notes, :inverse_of => 'InstallOrderNote'

  has_many :mod_version_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_versions, :through => 'mod_version_install_order_notes', :inverse_of => 'install_order_notes'

  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'

  validates :install_first, :install_second, presence: true
  validates :text_body, length: { in: 64..16384 }
  after_initialize :init

  def init
    self.submitted ||= DateTime.now
  end

  def as_json(options={})
    super(:include => {
        :mod_version => {
            :except => [:id, :released, :obsolete, :dangerous]
        }
    })
  end
end
