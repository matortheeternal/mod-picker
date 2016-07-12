class FixCompatibilityNotesColumnOrder < ActiveRecord::Migration
  def change
    change_column :compatibility_notes, :first_mod_id, :integer, null: false, after: :status
  end
end
