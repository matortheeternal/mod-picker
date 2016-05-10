class RefactorUserBios < ActiveRecord::Migration
  def change
    change_column :user_bios, :nexus_user_id, :string, limit: 64
    rename_column :user_bios, :nexus_user_id, :nexus_user_path
  end
end
