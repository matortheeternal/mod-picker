class AddIsEsmToPlugins < ActiveRecord::Migration
  def change
    add_column :plugins, :is_esm, :boolean, default: false, null: true
    Plugin.where("filename LIKE '%.esm'").update_all(is_esm: true)
  end
end
