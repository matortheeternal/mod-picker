class AddModOptionDisplayName < ActiveRecord::Migration
  def change
    add_column :mod_options, :display_name, :string, limit: 128, after: :name
    ModOption.update_all("mod_options.display_name = mod_options.name")
    
    change_column :mod_options, :name, :string, limit: 128, null: false
    change_column :mod_options, :display_name, :string, limit: 128, null: false
  end
end
