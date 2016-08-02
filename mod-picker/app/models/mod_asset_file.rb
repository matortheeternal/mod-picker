class ModAssetFile < ActiveRecord::Base
  self.primary_keys = :mod_id, :asset_file_id

  # Scopes
  scope :mods, -> (mod_ids) { where(mod_id: mod_ids) }

  # Associations
  belongs_to :mod, :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # Validations
  validates :mod_id, :asset_file_id, presence: true

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  private
    def increment_counters
      self.asset_file.update_counter(:mod_asset_files_count, 1)
    end

    def decrement_counters
      self.asset_file.update_counter(:mod_asset_files_count, -1)
    end

end
