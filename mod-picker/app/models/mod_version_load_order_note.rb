class ModVersionLoadOrderNote < ActiveRecord::Base
  self.primary_keys = :mod_version_id, :load_order_note_id

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod_version, :inverse_of => 'mod_version_load_order_notes'
  belongs_to :load_order_note, :inverse_of => 'mod_version_load_order_notes'

  # Validations
  validates :mod_version_id, :load_order_note_id, presence: true
  
  private
    def increment_counter_caches
      self.mod_version.mod.install_order_notes_count += 1
      self.mod_version.mod.save
    end

    def decrement_counter_caches
      self.mod_version.mod.install_order_notes_count -= 1
      self.mod_version.mod.save
    end
end
