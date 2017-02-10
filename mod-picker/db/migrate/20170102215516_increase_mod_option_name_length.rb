class IncreaseModOptionNameLength < ActiveRecord::Migration
  def change
    change_column :mod_options, :name, :string, limit: 255
    change_column :mod_options, :display_name, :string, limit: 255
  end
end
