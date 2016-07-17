class AddCompletedDateToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :completed, :datetime, after: :submitted
  end
end
