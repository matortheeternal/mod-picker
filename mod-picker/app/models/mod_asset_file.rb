class ModAssetFile < ActiveRecord::Base
  include ScopeHelpers

  self.primary_keys = :mod_id, :asset_file_id

  # SCOPES
  ids_scope :mod_id

  # UNIQUE SCOPES
  scope :bsa, -> { joins(:asset_file).where("asset_files.path like '%.bsa'") }
  scope :conflicting, -> { joins("JOIN mod_asset_files mod_asset_files_right ON mod_asset_files.asset_file_id = mod_asset_files_right.asset_file_id").where("mod_asset_files.mod_id <> mod_asset_files_right.mod_id").order(:asset_file_id) }

  # Associations
  belongs_to :mod, :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # Validations
  validates :mod_id, presence: true

  # Callbacks
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
      self.asset_file.update_counter(:mod_asset_files_count, 1)
    end

    def decrement_counters
      self.asset_file.update_counter(:mod_asset_files_count, -1)
    end

end
