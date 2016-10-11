class AllowNullModOptionPluginRecords < ActiveRecord::Migration
  def change
    change_column :plugins, :mod_option_id, :integer, null: true
  end
end
