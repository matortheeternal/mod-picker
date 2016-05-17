class AddUpdatedColumnToMods < ActiveRecord::Migration
  def change
    rename_column :mods, :update_rate, :updated
    reversible do |dir|
      dir.up do
        execute("UPDATE mods SET updated=NULL;")
      end
    end
    change_column :mods, :updated, :datetime
  end
end
