class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :user_id
      t.string :username
      t.string :email
      t.string :hash
      t.integer :user_level
      t.string :title
      t.text :avatar
      t.datetime :joined
      t.datetime :last_seen
      t.integer :bio_id
      t.integer :set_id
      t.integer :rep_id
      t.integer :active_ml_id
      t.integer :active_mc_id

      t.timestamps null: false
    end
  end
end
