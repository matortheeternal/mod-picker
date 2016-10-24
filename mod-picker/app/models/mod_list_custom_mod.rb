class ModListCustomMod < ActiveRecord::Base
  include RecordEnhancements, ScopeHelpers, BetterJson

  # SCOPES
  value_scope :is_utility

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'custom_mods'

  # VALIDATIONS
  validates :mod_list_id, :index, :name, presence: true
  validates :is_utility, inclusion: [true, false]
  validates :description, length: {maximum: 4096}

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      if self.is_utility
        self.mod_list.update_counter(:custom_tools_count, 1)
      else
        self.mod_list.update_counter(:custom_mods_count, 1)
      end
    end

    def decrement_counters
      if self.is_utility
        self.mod_list.update_counter(:custom_tools_count, -1)
      else
        self.mod_list.update_counter(:custom_mods_count, -1)
      end
    end
end
