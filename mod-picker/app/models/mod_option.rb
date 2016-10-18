class ModOption < ActiveRecord::Base
  include BetterJson

  attr_accessor :asset_paths, :plugin_dumps

  # SCOPES
  scope :default, -> { where(default: true) }

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_options'

  has_many :plugins, :inverse_of => 'mod_option', :dependent => :nullify
  has_many :mod_asset_files, :inverse_of => 'mod_option'

  has_many :mod_list_mod_options, :inverse_of => 'mod_option', :dependent => :destroy

  # VALIDATIONS
  validates :name, :display_name, presence: true

  # CALLBACKS
  after_save :create_asset_files, :create_plugins, :update_counters
  before_destroy :clear_assets

  # INSTANCE METHODS
  def create_asset_files
    if @asset_paths
      clear_assets
      if !is_fomod_option
        basepaths = DataPathUtils.get_base_paths(@asset_paths)
      else
        basepaths = [""]
      end

      @asset_paths.each do |path|
        basepath = basepaths.find { |basepath| path.start_with?(basepath) }
        if basepath.nil?
          mod_asset_files.create(subpath: path)
        else
          asset_file = AssetFile.find_or_create_by(game_id: mod.game_id, path: path.sub(basepath, ''))
          mod_asset_files.create(asset_file_id: asset_file.id, subpath: basepath)
        end
      end
    end
  end

  def clear_assets
    mod_asset_files.destroy_all
  end

  def asset_file_paths
    mod_asset_files.eager_load(:asset_file).pluck(:subpath, :path).map { |item| item.join('') }
  end

  def update_existing_plugin(dump)
    plugin = Plugin.find(dump[:id])
    plugin.update(dump)
  end

  def create_new_plugin(dump)
    dump[:game_id] = mod.game_id
    plugin = Plugin.find_by(filename: dump[:filename], crc_hash: dump[:crc_hash])
    if plugin.nil?
      plugin = plugins.create(dump)
    else
      plugin.mod_option_id = id
      plugin.save!
    end
  end

  def create_plugins
    if @plugin_dumps
      @plugin_dumps.each do |dump|
        dump.has_key?(:id) ? update_existing_plugin(dump): create_new_plugin(dump)
      end
    end
  end

  def update_counters
    self.asset_files_count = mod_asset_files.count
    self.plugins_count = plugins.count
    self.update_columns({
        plugins_count: plugins_count,
        asset_files_count: asset_files_count
    })
  end
end