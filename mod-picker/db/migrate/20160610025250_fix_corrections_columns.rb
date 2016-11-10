class FixCorrectionsColumns < ActiveRecord::Migration
  def change
    change_column :corrections, :title, :string, limit: 64, null: true
    change_column :corrections, :mod_status, :integer, limit: 1, default: nil, null: true
  end
end
