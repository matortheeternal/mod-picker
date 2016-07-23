class ModListInstallOrderNote < ActiveRecord::Base
  enum status: [ :unresolved, :resolved, :ignored ]

  belongs_to :install_order_note, :inverse_of => 'mod_list_install_order_notes'
  belongs_to :mod_list, :inverse_of => 'mod_list_install_order_notes'

  # Validations
  validates :mod_list_id, :install_order_note_id, presence: true

  # Callbacks
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private Methods
  private
    # counter caches
    def increment_counter_caches
      self.mod_list.install_order_notes_count += 1
      self.mod_list.save
    end

    def decrement_counter_caches
      self.mod_list.install_order_notes_count -= 1
      self.mod_list.save
    end 
end
