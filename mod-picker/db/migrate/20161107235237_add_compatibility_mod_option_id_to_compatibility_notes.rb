class AddCompatibilityModOptionIdToCompatibilityNotes < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :compatibility_mod_option_id, :integer, after: :compatibility_mod_id
  end
end
