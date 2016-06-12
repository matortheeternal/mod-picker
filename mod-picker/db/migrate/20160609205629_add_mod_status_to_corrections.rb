class AddModStatusToCorrections < ActiveRecord::Migration
  def change
    change_column :corrections, :status, :integer, limit: 1, default: 0, null: false
    add_column :corrections, :mod_status, :integer, limit: 1, default: 0, null: false, after: :status
  end
end
