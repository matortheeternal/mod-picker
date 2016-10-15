class ModListCustomConfigFile < ActiveRecord::Base
  include BetterJson

  belongs_to :mod_list, :inverse_of => 'custom_config_files'

  # VALIDATIONS
  validates :mod_list_id, :filename, :install_path, presence: true
  validates :text_body, length: {maximum: 8192}

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.mod_list.update_counter(:custom_config_files_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:custom_config_files_count, -1)
    end
end
