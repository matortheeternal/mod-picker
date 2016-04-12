class AddStatusColumnToMods < ActiveRecord::Migration
  def change
    add_column :mods, :status, :integer, :limit => 1
  end
end
