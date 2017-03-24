class AssociateLoadOrderNotesByPluginFilenames < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      # create filename columns and set values
      add_column :load_order_notes, :first_plugin_filename, :string, after: :first_plugin_id
      add_column :load_order_notes, :second_plugin_filename, :string, after: :second_plugin_id
      LoadOrderNote.joins("INNER JOIN plugins first_plugins on first_plugins.id = load_order_notes.first_plugin_id INNER JOIN plugins second_plugins on second_plugins.id = load_order_notes.second_plugin_id").update_all("first_plugin_filename = first_plugins.filename, second_plugin_filename = second_plugins.filename")

      # remove first_plugin_id and second_plugin_id columns
      remove_foreign_key "load_order_notes", column: "first_plugin_id"
      remove_foreign_key "load_order_notes", column: "second_plugin_id"
      remove_column :load_order_notes, :first_plugin_id
      remove_column :load_order_notes, :second_plugin_id

      # disallow null values on first_plugin_filename and second_plugin_filename columns
      change_column :load_order_notes, :first_plugin_filename, :string, null: false
      change_column :load_order_notes, :second_plugin_filename, :string, null: false
    end
  end
end
