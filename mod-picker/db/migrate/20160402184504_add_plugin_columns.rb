class AddPluginColumns < ActiveRecord::Migration
  def change
    add_column :plugins, :new_records, :integer
    add_column :plugins, :override_records, :integer
    add_column :plugins, :file_size, :integer
  end
end
