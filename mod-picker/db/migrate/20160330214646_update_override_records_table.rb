class UpdateOverrideRecordsTable < ActiveRecord::Migration
  def change
    remove_column :override_records, :master_index
  end
end
