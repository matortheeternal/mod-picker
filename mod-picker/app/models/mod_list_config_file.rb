class ModListConfigFile < ActiveRecord::Base
  belongs_to :mod_list, :inverse_of => 'mod_list_config_files'
  belongs_to :config_file, :inverse_of => 'mod_list_config_files'

  # validations
  validates :mod_list_id, :config_file_id, presence: true
  validates :text_body, length: { maximum: 8192}
  # can only have a mod on a given mod list once
  validates :config_file_id, uniqueness: { scope: :mod_list_id, :message => "The config file already present on the mod list." }

  # Callbacks
  before_create :set_default_text_body
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options =   {
          :only => [:id, :text_body],
          :include => {
              :config_file => {
                  :only => [:id, :filename, :install_path],
                  :include => {
                      :mod => {
                          :only => [:id, :name]
                      }
                  }
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def set_default_text_body
      self.text_body ||= self.config_file.text_body
    end

    def increment_counters
      self.mod_list.update_counter(:config_files_count, 1)
      self.config_file.update_counter(:mod_lists_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:config_files_count, -1)
      self.config_file.update_counter(:mod_lists_count, -1)
    end
end
