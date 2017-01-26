class AddModOptionsCountToMods < ActiveRecord::Migration
  def change
    add_column :mods, :mod_options_count, :integer, default: 0, null: false, after: :reputation
  end
end
