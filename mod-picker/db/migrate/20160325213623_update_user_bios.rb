class UpdateUserBios < ActiveRecord::Migration
  def change
    rename_column :user_bios, :nexus_verified, :nexus_verification_token
    change_column :user_bios, :nexus_verification_token, :string, limit: 32
    rename_column :user_bios, :lover_verified, :lover_verification_token
    change_column :user_bios, :lover_verification_token, :string, limit: 32
    add_column :user_bios, :nexus_user_id, :integer
    add_column :user_bios, :lover_user_path, :string, limit: 64
    add_column :user_bios, :nexus_date_joined, :date
    add_column :user_bios, :nexus_posts_count, :integer, default: 0
    add_column :user_bios, :lover_date_joined, :date
    add_column :user_bios, :lover_posts_count, :integer, default: 0
    add_column :user_bios, :steam_submissions_count, :integer, default: 0
    add_column :user_bios, :steam_followers_count, :integer, default: 0
  end
end
