class ModRequirement < EnhancedRecord::Base
  self.primary_keys = :mod_id, :required_id

  belongs_to :mod, :inverse_of => 'required_mods'
  belongs_to :required_mod, :class_name => 'Mod', :inverse_of => 'required_by', :foreign_key => 'required_id'

  # Callbacks
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private methods
  private
    def increment_counter_caches
      self.mod.update_counter(:required_mods_count, 1)
      self.required_mod.update_counter(:required_by_count, 1)
    end

    def decrement_counter_caches
      self.mod.update_counter(:required_mods_count, -1)
      self.required_mod.update_counter(:required_by_count, -1)
    end
end
