class FixCorrectionsColumnOrder < ActiveRecord::Migration
  def change
    change_column :corrections, :submitted_by, :integer, null: false, after: :game_id
    change_column :corrections, :edited_by, :integer, after: :submitted_by
  end
end
