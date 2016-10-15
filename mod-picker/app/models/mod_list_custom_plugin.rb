class ModListCustomPlugin < ActiveRecord::Base
  include BetterJson

  belongs_to :mod_list, :inverse_of => 'custom_plugins'

  # VALIDATIONS
  validates :mod_list_id, :index, :filename, presence: true
  validates :merged, :cleaned, inclusion: [true, false]
  validates :description, length: {maximum: 4096}

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.mod_list.update_counter(:custom_plugins_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:custom_plugins_count, -1)
    end
end
