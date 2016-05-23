class RenameParentCommentToParentId < ActiveRecord::Migration
  def change
    rename_column :comments, :parent_comment, :parent_id
  end
end
