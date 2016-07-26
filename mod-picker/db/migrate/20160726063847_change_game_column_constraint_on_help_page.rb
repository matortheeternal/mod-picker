class ChangeGameColumnConstraintOnHelpPage < ActiveRecord::Migration
  def change
    change_column_null(:help_pages, :game_id, true)
  end
end
