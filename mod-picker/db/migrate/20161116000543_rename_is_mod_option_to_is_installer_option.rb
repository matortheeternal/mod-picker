class RenameIsModOptionToIsInstallerOption < ActiveRecord::Migration
  def change
    rename_column :mod_options, :is_fomod_option, :is_installer_option
  end
end
