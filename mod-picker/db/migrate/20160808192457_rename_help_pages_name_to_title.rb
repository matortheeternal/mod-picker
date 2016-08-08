class RenameHelpPagesNameToTitle < ActiveRecord::Migration
  def change
    rename_column :help_pages, :name, :title
  end
end
