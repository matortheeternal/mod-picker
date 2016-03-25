class FixUsersActiveMlColumns < ActiveRecord::Migration
  def change
    remove_foreign_key :users, column: :active_mc_id
    remove_column :users, :active_mc_id
    rename_column :users, :active_ml_id, :active_mod_list_id
  end
end
