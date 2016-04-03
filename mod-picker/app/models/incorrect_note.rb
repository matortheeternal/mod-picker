class IncorrectNote < ActiveRecord::Base
  include Filterable

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'incorrect_notes'
  has_many :agreement_marks, :inverse_of => 'incorrect_note'
  
  belongs_to :correctable, :polymorphic => true

  validates :text_body, length: { in: 64..16384 }
  validates :correctable_id, :correctable_type, presence: true
  validates :correctable_type, inclusion: { in: ["CompatibilityNote", "InstallationNote", "Review"],
                                            message: "Not a valid record type that can contain incorrect notes"}

  after_initialize :init                                            

  def init
    self.created_at ||= DateTime.now
  end
end
