class ModListCustomPlugin < ActiveRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  belongs_to :mod_list, :inverse_of => 'custom_plugins'

  # Validations
  validates :mod_list_id, presence: true

  private
    # counter caches
    def increment_counter_caches
      self.mod_list.custom_plugins_count += 1
      self.mod_list.save
    end

    def decrement_counter_caches
      self.mod_list.custom_plugins_count -= 1
      self.mod_list.save
    end 
end
