class RenameDisableHelperColumn < ActiveRecord::Migration
  def change
    rename_column :user_settings, :helper_disabled, :disable_helper
  end
end
