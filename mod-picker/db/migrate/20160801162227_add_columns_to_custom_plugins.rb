class AddColumnsToCustomPlugins < ActiveRecord::Migration
  def change
    add_column :mod_list_custom_plugins, :cleaned, :boolean, default: false, null: false, after: :index
    add_column :mod_list_custom_plugins, :merged, :boolean, default: false, null: false, after: :cleaned
    add_column :mod_list_custom_plugins, :compatibility_note_id, :integer, after: :merged
    remove_column :mod_list_custom_plugins, :active
  end
end
