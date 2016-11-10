class AddColumnsToModOptions < ActiveRecord::Migration
  def change
    add_column :mod_options, :size, :integer, limit: 8, default: 0, null: false, after: :name
    add_column :mod_options, :is_fomod_option, :boolean, default: false, null: false, after: :default

    remove_column :mod_list_mod_options, :enabled
  end
end
