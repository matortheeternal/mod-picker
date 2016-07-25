class MakeArticleGameIdOptional < ActiveRecord::Migration
  def change
    change_column :articles, :game_id, :integer, null: true
  end
end
