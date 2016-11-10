class AddGameAndCategoryToHelpPage < ActiveRecord::Migration
  def change
    add_reference :help_pages, :game, index: true, foreign_key: true, null: false
    add_column :help_pages, :category, :integer, limit: 1, null: false, default: 0
  end
end
