class AddModOptions < ActiveRecord::Migration
  def change
    # Create Mod Options table
    create_table "mod_options" do |t|
      t.integer :mod_id, null: false
      t.string :name, null: false
      t.boolean :default, default: false, null: false
      t.integer :asset_files_count, default: 0, null: false
      t.integer :plugins_count, default: 0, null: false
    end

    add_foreign_key :mod_options, :mods

    # Create Mod Options for existing mods
    Mod.all.each do |mod|
      option = ModOption.new({
          mod_id: mod.id,
          name: mod.name + ".zip",
          default: true
      })
      option.id = mod.id
      option.save!
    end

    # Update Mod Asset Files table
    remove_foreign_key :mod_asset_files, :mods
    rename_column :mod_asset_files, :mod_id, :mod_option_id
    add_foreign_key :mod_asset_files, :mod_options

    # Update Plugins table
    remove_foreign_key :plugins, :mods
    rename_column :plugins, :mod_id, :mod_option_id
    add_foreign_key :plugins, :mod_options
  end
end
