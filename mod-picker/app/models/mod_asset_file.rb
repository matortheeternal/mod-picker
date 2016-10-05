class ModAssetFile < ActiveRecord::Base
  include ScopeHelpers

  self.primary_keys = :mod_option_id, :asset_file_id

  # SCOPES
  ids_scope :mod_option_id

  # UNIQUE SCOPES
  scope :bsa, -> { joins(:asset_file).where("asset_files.path like '%.bsa'") }
  scope :conflicting, -> { joins("JOIN mod_asset_files mod_asset_files_right ON mod_asset_files.asset_file_id = mod_asset_files_right.asset_file_id").where("mod_asset_files.mod_option_id <> mod_asset_files_right.mod_option_id").where("mod_asset_files.asset_file_id IS NOT NULL").order(:asset_file_id) }

  # ASSOCIATIONS
  belongs_to :mod_option, :inverse_of => 'mod_asset_files'
  has_one :mod, :through => 'mod_option', :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [],
          :include => {
              :asset_file => {
                  :only => [:path]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def increment_counters
      asset_file.update_counter(:mod_asset_files_count, 1) if asset_file_id
    end

    def decrement_counters
      asset_file.update_counter(:mod_asset_files_count, -1) if asset_file_id
    end
end
