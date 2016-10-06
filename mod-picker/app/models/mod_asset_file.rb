class ModAssetFile < ActiveRecord::Base
  include ScopeHelpers

  self.primary_keys = :mod_option_id, :asset_file_id

  # SCOPES
  ids_scope :mod_option_id

  # UNIQUE SCOPES
  scope :bsa, -> { joins(:asset_file).where("asset_files.path like '%.bsa'") }
  scope :conflicting, -> (mod_option_ids) {
    joins(conflicting_join_sources).
        where(mod_options[:mod_id].not_eq(mod_options_right[:mod_id])).
        where(mod_asset_files[:asset_file_id].not_eq(nil)).
        where(mod_asset_files[:mod_option_id].in(mod_option_ids)).
        where(mod_asset_files_right[:mod_option_id].in(mod_option_ids)).
        order(mod_asset_files[:asset_file_id])
  }

  # ASSOCIATIONS
  belongs_to :mod_option, :inverse_of => 'mod_asset_files'
  has_one :mod, :through => 'mod_option', :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def self.mod_asset_files
    @mod_asset_files ||= arel_table
  end

  def self.mod_asset_files_right
    @mod_asset_files_right ||= arel_table.alias
  end

  def self.mod_options
    @mod_options ||= ModOption.arel_table
  end

  def self.mod_options_right
    @mod_options_right ||= ModOption.arel_table.alias
  end

  def self.conflicting_join_sources
    mod_asset_files.join(mod_asset_files_right).on(mod_asset_files[:asset_file_id].
        eq(mod_asset_files_right[:asset_file_id])).
        join(mod_options).on(mod_options[:id].
        eq(mod_asset_files[:mod_option_id])).
        join(mod_options_right).on(mod_options_right[:id].
        eq(mod_asset_files_right[:mod_option_id])).join_sources
  end

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
