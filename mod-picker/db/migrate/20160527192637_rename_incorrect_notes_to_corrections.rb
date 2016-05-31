class RenameIncorrectNotesToCorrections < ActiveRecord::Migration
  def change
    rename_table :incorrect_notes, :corrections
  end
end
