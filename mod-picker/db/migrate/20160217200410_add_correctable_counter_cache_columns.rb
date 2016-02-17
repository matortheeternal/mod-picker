class AddCorrectableCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :incorrect_notes_count, :integer
    add_column :installation_notes, :incorrect_notes_count, :integer
    add_column :reviews, :incorrect_notes_count, :integer
  end
end
