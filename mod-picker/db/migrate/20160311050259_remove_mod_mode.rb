class RemoveModMode < ActiveRecord::Migration
  def change
    remove_column :compatibility_notes, :mod_mode
  end
end
