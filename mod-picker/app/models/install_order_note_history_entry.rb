class InstallOrderNoteHistoryEntry < EnhancedRecord::Base
  after_initialize :init

  belongs_to :install_order_note, :inverse_of => 'install_order_note_history_entries'
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'install_order_note_history_entries'

  # enum status: [ :incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch" ]

  # Validations
  validates :edit_summary, :install_first, :install_second, :submitted, presence: true
  validates :text_body, length: { in: 64..16384 }

  def init 
    self.submitted  ||= DateTime.now
  end
end