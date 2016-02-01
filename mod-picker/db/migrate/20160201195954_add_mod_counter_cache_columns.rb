class AddModCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :mods, :user_stars_count, :integer
    add_column :mods, :reviews_count, :integer
    add_column :mods, :comments_count, :integer
    add_column :mods, :mod_versions_count, :integer
  end
end
