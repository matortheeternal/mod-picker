class CompatibilityNoteHistoryEntry < EnhancedRecord::Base
  after_initialize :init

  belongs_to :compatibility_note, :inverse_of => 'compatibility_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'compatibility_note_history_entries'

  enum status: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  # validations
  validates :compatibility_note_id, :edit_summary, :submitted_by, :submitted, presence: true
  validates :edit_summary, length: {in: 0..255}
  validates :text_body, length: {in: 64..16384}

  def init
    self.submitted  ||= DateTime.now
  end
end
