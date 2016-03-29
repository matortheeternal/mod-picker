class RemoveCommentsCountFromMods < ActiveRecord::Migration
  def change
    remove_column :mods, :comments_count
  end
end
