class AddModListCustomConfigFilesTable < ActiveRecord::Migration
  def change
    create_table :mod_list_custom_config_files do |t|
      t.integer   :mod_list_id, null: false
      t.string    :filename, null: false, limit: 64
      t.string    :install_path, null: false, limit: 128
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :mod_list_custom_config_files, :mod_lists
  end
end
