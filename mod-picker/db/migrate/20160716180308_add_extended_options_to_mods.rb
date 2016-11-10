class AddExtendedOptionsToMods < ActiveRecord::Migration
  def change
    add_column :mods, :disallow_contributors, :boolean, default: false, null: false, after: :corrections_count
    add_column :mods, :disable_reviews, :boolean, default: false, null: false, after: :disallow_contributors
    add_column :mods, :lock_tags, :boolean, default: false, null: false, after: :disable_reviews
  end
end
