class FixDummyMastersColumns < ActiveRecord::Migration
  def change
    change_column :dummy_masters, :index, :integer, limit: 1, null: false
    change_column :dummy_masters, :filename, :string, limit: 128, null: false
  end
end
