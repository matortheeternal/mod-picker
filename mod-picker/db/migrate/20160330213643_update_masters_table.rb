class UpdateMastersTable < ActiveRecord::Migration
  def change
    add_column :masters, :master_plugin_id, :integer
    add_column :masters, :index, :integer

    # remove foreign keys referencing masters and master id column
    remove_foreign_key :override_records, column: :master_id
    rename_column :override_records, :master_id, :master_index
    remove_column :masters, :id
  end
end
