class AddApprovedToMods < ActiveRecord::Migration
  def change
    add_column :mods, :approved, :boolean, default: false, null: false, after: :hidden
  end
end
