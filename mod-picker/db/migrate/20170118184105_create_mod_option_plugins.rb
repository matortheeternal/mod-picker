class CreateModOptionPlugins < ActiveRecord::Migration
  def change
    create_table :mod_option_plugins do |t|
      t.integer :mod_option_id, null: false
      t.integer :plugin_id, null: false
    end

    add_foreign_key :mod_option_plugins, :mod_options
    add_foreign_key :mod_option_plugins, :plugins

    Plugin.all.find_each do |p|
      ModOptionPlugin.create(plugin_id: p.id, mod_option_id: p.mod_option_id)
    end

    remove_foreign_key :plugins, :mod_options
    remove_column :plugins, :mod_option_id
  end
end
