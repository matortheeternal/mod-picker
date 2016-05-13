class LoadOrderNote < ActiveRecord::Base
  include Filterable

  after_initialize :init

  scope :by, -> (id) { where(submitted_by: id) }
  scope :mod, -> (id) { joins(:mod_versions).where(:mod_versions => {mod_id: id}) }
  scope :mv, -> (id) { joins(:mod_versions).where(:mod_versions => {id: id}) }

  belongs_to :game, :inverse_of => 'load_order_notes'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'load_order_notes'

  # plugins associatied with this load order note
  belongs_to :first_plugin, :foreign_key => 'first_plugin_id', :class_name => 'Plugin', :inverse_of => 'load_before_notes'
  belongs_to :second_plugin, :foreign_key => 'second_plugin_id', :class_name => 'Plugin', :inverse_of => 'load_after_notes'

  # mods associated with this load order note
  has_one :first_mod, :through => :first_plugin, :class_name => 'Mod', :foreign_key => 'mod_id'
  has_one :second_mod, :through => :second_plugin, :class_name => 'Mod', :foreign_key => 'mod_id'

  # mod lists this load order note appears on
  has_many :mod_list_installation_notes, :inverse_of => 'load_order_note'
  has_many :mod_lists, :through => 'mod_list_load_order_notes', :inverse_of => 'load_order_notes'

  # community feedback on this load order note
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'
  has_one :base_report, :as => 'reportable'

  validates :first_plugin_id, :second_plugin_id, presence: true
  validates :text_body, length: {in: 64..16384}

  def init
    self.submitted ||= DateTime.now
  end

  def mods
    [first_mod, second_mod]
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
