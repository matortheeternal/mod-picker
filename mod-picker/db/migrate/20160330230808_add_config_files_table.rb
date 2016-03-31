class AddConfigFilesTable < ActiveRecord::Migration
  def change
    create_table :config_files do |t|
      t.integer   :game_id, null: false
      t.string    :filename, null: false, limit: 64
      t.string    :install_path, null: false, limit: 128
    end

    add_foreign_key :config_files, :games
    add_index :config_files, [:game_id, :filename]
  end
end
