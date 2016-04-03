class AddModListConfigFilesTable < ActiveRecord::Migration
  def change
    create_table :mod_list_config_files, id: false do |t|
      t.integer   :mod_list_id, null: false
      t.integer   :config_file_id, null: false
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :mod_list_config_files, :mod_lists
    add_foreign_key :mod_list_config_files, :config_files
  end
end
