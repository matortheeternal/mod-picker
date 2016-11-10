class CreateCuratorRequests < ActiveRecord::Migration
  def change
    create_table :curator_requests do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :mod, index: true, foreign_key: true, null: false
      t.string :message, null: false
      t.integer :state, limit: 1, default: 0, null: false
    end
  end
end
