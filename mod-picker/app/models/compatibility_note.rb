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

  validates :submitted_by, presence: true
  validates :compatibility_type, inclusion: { in: ["Incompatible", "Partially Incompatible", "Compatibility Mod", "Compatibility Plugin", "Make Custom Patch"],
                                              message: "Not a valid compatibility type" }
  validates :text_body, length: { in: 64..16384 }, allow_blank: true, allow_nil: true                                             
  
  # validate :submitted_must_be_recent, on: :create

  after_initialize :init
  
  def init
    self.submitted = Date.today
  end     


  # alternate method to allow defining of custom submitted Date

  # def submitted_must_be_recent
  #   puts "is this even being ran?"
  #   if submitted.present? && submitted < Date.today
  #     errors.add(:submitted, "Date upon creation must be equal to today")
  #   elsif !submitted.present?
  #     self.submitted = Date.today
  #   end
  # end                       

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
