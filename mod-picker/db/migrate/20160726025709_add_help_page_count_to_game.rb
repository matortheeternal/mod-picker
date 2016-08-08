class AddHelpPageCountToGame < ActiveRecord::Migration
  def change
    add_column :games, :help_pages_count, :integer, default: 0, null: false
  end
end
