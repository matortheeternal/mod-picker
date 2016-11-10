class AddMissingCorrectionsColumns < ActiveRecord::Migration
  def change
    add_column :corrections, :status, :integer, limit: 1, default: 0
    add_column :corrections, :title, :string, limit: 64, null: false
    change_column :corrections, :submitted_by, :integer, null: false
    change_column :corrections, :text_body, :text, null: false
    change_column :corrections, :correctable_id, :integer, null: false
    change_column :corrections, :correctable_type, :string, null: false
  end
end
