class AddIdToDummyMasters < ActiveRecord::Migration
  def change
    add_column :dummy_masters, :id, :primary_key
  end
end
