class AddModSubmittedColumn < ActiveRecord::Migration
  def change
    add_column :mods, :submitted, :datetime
    Mod.update_all(submitted: DateTime.now)
    change_column :mods, :submitted, :datetime, null: false
  end
end
