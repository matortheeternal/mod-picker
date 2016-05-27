class RefactorUserBioSteamColumns < ActiveRecord::Migration
  def change
    rename_column :user_bios, :steam_username, :workshop_username
    rename_column :user_bios, :steam_verified, :workshop_verified
    rename_column :user_bios, :steam_submissions_count, :workshop_submissions_count
    rename_column :user_bios, :steam_followers_count, :workshop_followers_count
  end
end
