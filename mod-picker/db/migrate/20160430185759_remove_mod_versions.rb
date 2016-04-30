class RemoveModVersions < ActiveRecord::Migration
  def change
    ### mod_version_requirements ###
    # remove foreign keys
    remove_foreign_key :mod_version_requirements, column: :mod_version_id
    remove_foreign_key :mod_version_requirements, column: :required_id
    # rename columns
    rename_column :mod_version_requirements, :mod_version_id, :mod_id
    # rename table
    rename_table :mod_version_requirements, :mod_requirements
    # add foreign keys
    add_foreign_key :mod_requirements, :mods, column: :mod_id
    add_foreign_key :mod_requirements, :mods, column: :required_id

    ### mod_version_files ###
    # remove foreign keys
    remove_foreign_key :mod_version_files, :mod_versions
    remove_foreign_key :mod_version_files, :mod_asset_files
    # rename columns
    rename_column :mod_version_files, :mod_version_id, :mod_id
    rename_column :mod_version_files, :mod_asset_file_id, :asset_file_id
    # rename tables
    rename_table :mod_asset_files, :asset_files
    rename_table :mod_version_files, :mod_asset_files
    # add foreign keys
    add_foreign_key :mod_asset_files, :asset_files
    add_foreign_key :mod_asset_files, :mods

    ### mod_version_compatibility_notes ###
    # add columns to compatibility_notes
    add_column :compatibility_notes, :first_mod, :integer
    add_column :compatibility_notes, :second_mod, :integer
    # add foreign keys to compatibility notes
    add_foreign_key :compatibility_notes, :mods, column: :first_mod
    add_foreign_key :compatibility_notes, :mods, column: :second_mod
    # drop old many-to-many table
    drop_table :mod_version_compatibility_notes

    ### mod_version_install_order_notes ###
    # drop old many-to-many table
    drop_table :mod_version_install_order_notes

    ### mod_version_load_order_notes ###
    # drop old many-to-many table
    drop_table :mod_version_load_order_notes

    ### mod ###
    # drop unneeded counter_cache column
    remove_column :mods, :mod_versions_count

    ### plugin ###
    # remove foreign key
    remove_foreign_key :plugins, :mod_versions
    # rename columns
    rename_column :plugins, :mod_version_id, :mod_id
    # add foreign key
    add_foreign_key :plugins, :mods, column: :mod_id

    ### mod_versions ###
    # drop unneeded table
    drop_table :mod_versions


  end
end
