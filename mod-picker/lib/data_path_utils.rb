module DataPathUtils
  def self.is_data_folder(node)
    /data|.*\.bsa/i =~ node
  end

  def self.in_data_folder(node)
    /.*\.esp|.*\.esm|scripts|textures|meshes|sounds|music|interface|video|strings|seq|skse|lodsettings|dialogueviews/i =~ node
  end

  def self.rebuild_path(nodes, index)
    return "" if index == -1
    nodes[0..index].join('\\') + '\\'
  end

  def self.get_base_path(path)
    path_nodes = path.split('\\')
    path_nodes.each_with_index do |node, index|
      return rebuild_path(path_nodes, index) if is_data_folder(node)
      return rebuild_path(path_nodes, index - 1) if in_data_folder(node)
    end
    nil
  end

  def self.get_base_paths(asset_paths)
    base_paths = asset_paths.map { |path| get_base_path(path) }.compact.uniq
    base_paths.sort { |a,b| b.length - a.length }
  end
end