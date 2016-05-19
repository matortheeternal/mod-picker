class RefactorWorkshopAccountLinking < ActiveRecord::Migration
  def change
    rename_column :user_bios, :workshop_username, :workshop_user_path
    rename_column :user_bios, :workshop_verified, :workshop_username
    change_column :user_bios, :workshop_user_path, :string, limit: 64
    change_column :user_bios, :workshop_username, :string, limit: 32
  end
end
