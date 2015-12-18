class CreateUserReputations < ActiveRecord::Migration
  def change
    create_table :user_reputations do |t|
      t.integer :rep_id
      t.float :overall
      t.float :offset
      t.float :audiovisual_design
      t.float :plugin_design
      t.float :utilty_design
      t.float :script_design

      t.timestamps null: false
    end
  end
end
