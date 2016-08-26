class AddModListModOptions < ActiveRecord::Migration
  def change
    create_table "mod_list_mod_options" do |t|
      t.integer :mod_list_mod_id, null: false
      t.integer :mod_option_id, null: false
      t.boolean :enabled, default: true, null: false
    end

    add_foreign_key :mod_list_mod_options, :mod_list_mods
    add_foreign_key :mod_list_mod_options, :mod_options
  end
end
