class ModAssetFile < ActiveRecord::Base
  include ScopeHelpers, BetterJson, CounterCache

  self.primary_keys = :mod_option_id, :asset_file_id

  # SCOPES
  ids_scope :mod_option_id

  # UNIQUE SCOPES
  scope :bsa, -> { joins(:asset_file).where("asset_files.path like '%.bsa'") }
  scope :conflicting, -> (mod_option_ids) {
    joins(conflicting_join_sources).
        where(mod_options_table[:mod_id].not_eq(mod_options_right[:mod_id])).
        where(mod_asset_files[:asset_file_id].not_eq(nil)).
        where(mod_asset_files[:mod_option_id].in(mod_option_ids)).
        where(mod_asset_files_right[:mod_option_id].in(mod_option_ids)).
        order(mod_asset_files[:asset_file_id])
  }

  # ASSOCIATIONS
  belongs_to :mod_option, :inverse_of => 'mod_asset_files'
  has_one :mod, :through => 'mod_option', :inverse_of => 'mod_asset_files'
  belongs_to :asset_file, :inverse_of => 'mod_asset_files'

  # COUNTER CACHE
  counter_cache_on :asset_file

  def self.mod_asset_files
    @mod_asset_files ||= arel_table
  end

  def self.mod_asset_files_right
    @mod_asset_files_right ||= arel_table.alias
  end

  def self.mod_options_table
    @mod_options ||= ModOption.arel_table
  end

  def self.mod_options_right
    @mod_options_right ||= ModOption.arel_table.alias
  end

  def self.conflicting_join_sources
    mod_asset_files.join(mod_asset_files_right).on(mod_asset_files[:asset_file_id].
        eq(mod_asset_files_right[:asset_file_id])).
        join(mod_options_table).on(mod_options_table[:id].
        eq(mod_asset_files[:mod_option_id])).
        join(mod_options_right).on(mod_options_right[:id].
        eq(mod_asset_files_right[:mod_option_id])).join_sources
  end

  def self.apply_base_paths(game_id, collection, base_paths)
    collection.each do |maf|
      path = maf.subpath
      basepath = base_paths.find { |basepath| path.start_with?(basepath) }
      next unless basepath.present?
      asset_file = AssetFile.find_or_create_by(game_id: game_id, path: path.sub(basepath, ''))
      maf.update(asset_file_id: asset_file.id, subpath: basepath)
    end
  end
end
