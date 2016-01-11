class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.integer :set_id
      t.integer :user_id
      t.boolean :show_notifications
      t.boolean :show_tooltips
      t.boolean :email_notifications
      t.boolean :email_public
      t.boolean :allow_adult_content
      t.boolean :allow_nexus_mods
      t.boolean :allow_lovers_lab
      t.boolean :allow_steam_workshop

      t.timestamps null: false
    end
  end
end
