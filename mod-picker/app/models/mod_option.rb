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

  # CALLBACKS
  after_create :create_asset_files, :create_plugins, :update_counters
  before_destroy :destroy_mod_asset_files

  # INSTANCE METHODS
  def create_asset_files
    if @asset_paths
      if !is_fomod_option
        basepaths = []
        @asset_paths.each do |path|
          # prioritize files over data folder matching
          split_paths = path.split(/(?<=\.bsa\\|\.esp|\.esm|Data\\)/)
          basepaths |= [split_paths[0]] if split_paths.length > 1
        end
        # sort by longest path first so nested paths are prioritized
        basepaths.sort { |a,b| b.length - a.length }
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

  def destroy_mod_asset_files
    query = "DELETE FROM mod_asset_files WHERE mod_option_id = #{id}"
    ActiveRecord::Base.connection.execute(query)
  end

  def create_plugins
    if @plugin_dumps
      @plugin_dumps.each do |dump|
        # create plugin from dump
        dump[:game_id] = mod.game_id
        plugin = Plugin.find_by(filename: dump[:filename], crc_hash: dump[:crc_hash])
        if plugin.nil?
          plugin = plugins.create(dump)
        else
          plugin.mod_option_id = id
          plugin.save!
        end
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