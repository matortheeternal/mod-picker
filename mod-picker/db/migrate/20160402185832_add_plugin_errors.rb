class AddPluginErrors < ActiveRecord::Migration
  def change
    create_table :plugin_errors do |t|
      t.integer   :plugin_id, null: false
      t.string    :signature, limit: 4, null: false
      t.integer   :form_id, limit: 4, null: false
      t.integer   :type, limit: 1, null: false
      t.string    :path, limit: 255
      t.string    :name, limit: 255
      t.string    :data, limit: 64
    end

    # add foreign keys
    add_foreign_key :plugin_errors, :plugins

    # rename sig columns to "signature"
    rename_column :plugin_record_groups, :sig, :signature
    rename_column :override_records, :sig, :signature
  end
end
