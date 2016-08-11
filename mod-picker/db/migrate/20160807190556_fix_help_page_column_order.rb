class FixHelpPageColumnOrder < ActiveRecord::Migration
  def change
    change_table "help_pages" do |t|
      t.change :game_id, :integer, after: :id
      t.change :category, :integer, limit: 1, default: 0, null: false, after: :game_id
      t.change :submitted_by, :integer, null: false, after: :category
    end
  end
end
