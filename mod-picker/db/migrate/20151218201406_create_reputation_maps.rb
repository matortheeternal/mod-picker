class CreateReputationMaps < ActiveRecord::Migration
  def change
    create_table :reputation_maps do |t|
      t.integer :from_rep_id
      t.integer :to_rep_id

      t.timestamps null: false
    end
  end
end
