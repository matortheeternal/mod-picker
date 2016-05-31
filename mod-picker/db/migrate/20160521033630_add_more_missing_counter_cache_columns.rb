class AddMoreMissingCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :games, :corrections_count, :integer, default: 0
    add_column :plugins, :errors_count, :integer, default: 0
    add_column :plugins, :mod_lists_count, :integer, default: 0
    add_column :plugins, :load_order_notes_count, :integer, default: 0
  end
end
