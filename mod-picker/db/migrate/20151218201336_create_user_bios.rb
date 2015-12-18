class CreateUserBios < ActiveRecord::Migration
  def change
    create_table :user_bios do |t|
      t.integer :bio_id
      t.string :nexus_username
      t.boolean :nexus_verified
      t.string :lover_username
      t.boolean :lover_verified
      t.string :steam_username
      t.boolean :steam_verified

      t.timestamps null: false
    end
  end
end
