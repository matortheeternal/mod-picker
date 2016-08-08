class ModListCustomConfigFile < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'custom_config_files'

  # validations
  validates :mod_list_id, :filename, :install_path, presence: true
  validates :text_body, length: {maximum: 8192}

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options =   {
          :except => [:mod_list_id]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def increment_counters
      self.mod_list.update_counter(:custom_config_files_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:custom_config_files_count, -1)
    end
end
