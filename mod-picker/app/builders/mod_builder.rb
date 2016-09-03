class ModBuilder
  attr_accessor :mod, :current_user, :params, :asset_paths, :plugin_dumps, :tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id

  def builder_attributes
    [:asset_paths, :plugin_dumps, :tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id]
  end

  def initialize(current_user, **params)
    @current_user = current_user
    @params = params.except(attributes)
    builder_attributes.each_key do |attribute|
      send(:"#{attribute}=", params.delete(attribute)) if params.has_key?(attribute)
    end
  end

  def mod
    @mod ||= Mod.find_or_initialize_by(id: @params[:id])
  end

  def update
    update!
  rescue
    errors = @mod.errors
    false
  end

  def update!
    ActiveRecord::Base.transaction do
      self.before_save
      self.before_update
      mod.update!(@params)
      self.after_save
    end
  end

  def before_update
    hide_contributions
  end

  def save
    mod.assign_attributes(@params)
    mod.submitted_by = @current_user.id
    save!
  rescue
    errors = @mod.errors
    false
  end

  def save!
    ActiveRecord::Base.transaction do
      self.before_save
      mod.save!
      self.after_save
    end
  end

  def before_save
    set_config_file_game_ids
  end

  def after_save
    link_sources
    create_plugins
    create_asset_files
    create_tags
  end

  def set_config_file_game_ids
    if @config_files_attributes
      @config_files_attributes.each do |config_file|
        config_file[:game_id] = game_id
      end
    end
  end

  def hide_contributions
    if attribute_changed?(:hidden) && hidden
      # prepare some helper variables
      plugin_ids = plugins.ids
      cnote_ids = compatibility_notes.ids
      inote_ids = install_order_notes.ids
      lnote_ids = load_order_notes.ids

      # hide content
      reviews.update_all(:hidden => true)
      corrections.update_all(:hidden => true)
      compatibility_notes.update_all(:hidden => true)
      install_order_notes.update_all(:hidden => true)
      load_order_notes.update_all(:hidden => true)
      Correction.correctables("CompatibilityNote", cnote_ids).update_all(:hidden => true)
      Correction.correctables("InstallOrderNote", inote_ids).update_all(:hidden => true)
      Correction.correctables("LoadOrderNote", lnote_ids).update_all(:hidden => true)
    elsif attribute_changed?(:disable_reviews) && disable_reviews
      reviews.update_all(:hidden => true)
    end
  end

  def create_asset_files
    if @asset_paths
      mod_asset_files.destroy_all
      basepaths = []
      @asset_paths.each do |path|
        # prioritize files over data folder matching
        split_paths = path.split(/(?<=\.bsa\\|\.esp|\.esm|Data\\)/)
        basepaths |= [split_paths[0]] if split_paths.length > 1
      end
      # sort by longest path first so nested paths are prioritized
      basepaths.sort { |a,b| b.length - a.length }

      @asset_paths.each do |path|
        basepath = basepaths.find { |basepath| path.start_with?(basepath) }
        if basepath.present?
          asset_file = AssetFile.find_or_create_by(game_id: game_id, path: path.sub(basepath, ''))
          mod_asset_files.create(asset_file_id: asset_file.id, subpath: basepath)
        else
          mod_asset_files.create(subpath: path)
        end
      end
    end
  end

  def create_plugins
    if @plugin_dumps
      plugins.destroy_all
      @plugin_dumps.each do |dump|
        # create plugin from dump
        dump[:game_id] = game_id
        plugin = Plugin.find_by(filename: dump[:filename], crc_hash: dump[:crc_hash])
        if plugin.nil?
          plugin = plugins.create(dump)
        else
          plugin.mod_id = id
          plugin.save!
        end
      end
    end
  end

  def link_sources
    link_source(@nexus_info_id, NexusInfo)
    link_source(@lover_info_id, LoverInfo)
    link_source(@workshop_info_id, WorkshopInfo)
  end

  def link_source(info_id, model)
    if info_id
      info = NexusInfo.find(info_id)
      info.mod_id = id
      info.save!
    end
  end

  def create_tags
    if @tag_names
      @tag_names.each do |text|
        tag = Tag.find_by(text: text, game_id: game_id)

        # create tag if we couldn't find it
        if tag.nil?
          tag = Tag.create(text: text, game_id: game_id, submitted_by: submitted_by)
        end

        # associate tag with mod
        mod_tags.create(tag_id: tag.id, submitted_by: submitted_by)
      end
    end
  end

  def swap_mod_list_mods_tools_counts
    if attribute_changed?(:is_utility)
      tools_operator = is_utility ? "+" : "-"
      mods_operator = is_utility ? "-" : "+"
      mod_list_ids = mod_lists.ids
      ModList.where(id: mod_list_ids).update_all("tools_count = tools_count #{tools_operator} 1, mods_count = mods_count #{mods_operator} 1")
    end
  end

  def self.model_name
    'Mod'
  end

  def method_missing(method, *args, &block)
    if mod.respond_to? method
      mod.send method *args, &block
    else
      super
    end
  end
end