class InstallOrderNote < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'install_order_notes'

  # mods associatied with this install order note
  belongs_to :install_first_mod, :foreign_key => 'install_first', :class_name => 'Mod', :inverse_of => 'install_before_notes'
  belongs_to :install_second_mod, :foreign_key => 'install_second', :class_name => 'Mod', :inverse_of => 'install_after_notes'

  # mod lists this install order note appears on
  has_many :mod_list_install_order_notes, :inverse_of => 'install_order_note'
  has_many :mod_lists, :through => 'mod_list_install_order_notes', :inverse_of => 'install_order_notes'

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

  def mods
    [install_first_mod, install_second_mod]
  end

  def as_json(options={})
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
  end
end
