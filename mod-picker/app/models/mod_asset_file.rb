class ModAssetFile < ActiveRecord::Base
  self.primary_keys = :mod_id, :asset_file_id

  # Scopes
  scope :mods, -> (mod_ids) { where(mod_id: mod_ids) }
  scope :bsa, -> { joins(:asset_file).where("asset_files.filepath like '%.bsa'") }
  scope :conflicting, -> { where("EXISTS ( SELECT 1 FROM mod_asset_files maf WHERE maf.asset_file_id = mod_asset_files.asset_file_id LIMIT 1, 1)").order(:asset_file_id) }

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
