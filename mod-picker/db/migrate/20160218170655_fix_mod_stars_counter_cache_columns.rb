class FixModStarsCounterCacheColumns < ActiveRecord::Migration
  def change
    rename_column :mods, :user_stars_count, :mod_stars_count
    add_column :users, :mod_stars_count, :integer
  end
end
