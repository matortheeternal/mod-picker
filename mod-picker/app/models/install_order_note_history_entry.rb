class InstallOrderNoteHistoryEntry < ActiveRecord::Base
  belongs_to :install_order_note, :inverse_of => 'history_entries', :foreign_key => 'install_order_note_id'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by', :inverse_of => 'install_order_note_history_entries'

  # VALIDATIONS
  validates :install_order_note_id, :edited_by, :text_body, :edit_summary, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:install_order_note_id, :edited_by],
          :include => {
              :editor => {
                  :only => [:id, :username, :role, :title]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def increment_counters
      self.install_order_note.update_counter(:history_entries_count, 1)
    end

    def decrement_counters
      self.install_order_note.update_counter(:history_entries_count, -1)
    end
end