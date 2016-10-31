class ModListConfigFile < ActiveRecord::Base
  include BetterJson, CounterCache, ScopeHelpers

  # SCOPES
  ids_scope :config_file_id

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_config_files'
  belongs_to :config_file, :inverse_of => 'mod_list_config_files'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'config_files_count'
  counter_cache_on :config_file, column: 'mod_lists_count'

  # VALIDATIONS
  validates :mod_list_id, :config_file_id, presence: true
  validates :text_body, length: { maximum: 8192}
  # can only have a mod on a given mod list once
  validates :config_file_id, uniqueness: { scope: :mod_list_id, :message => "The config file already present on the mod list." }

  # CALLBACKS
  before_create :set_default_text_body

  private
    def set_default_text_body
      self.text_body ||= self.config_file.text_body
    end
end
