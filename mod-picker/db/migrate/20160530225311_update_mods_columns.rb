class UpdateModsColumns < ActiveRecord::Migration
  def change
    change_column :mods, :is_utility, :boolean, default: false
    change_column :mods, :has_adult_content, :boolean, default: false
    change_column :mods, :submitted_by, :integer, null: true
    change_column :mods, :name, :string, limit: 128, null: false
    change_column :mods, :aliases, :string, limit: 128
    change_column :mods, :game_id, :integer, null: false
    change_column :mods, :released, :datetime, null: false
    change_column :mods, :is_official, :boolean, default: false
  end
end
