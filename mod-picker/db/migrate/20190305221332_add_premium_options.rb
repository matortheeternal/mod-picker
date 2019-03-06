class AddPremiumOptions < ActiveRecord::Migration
  def change
    create_table :premium_options do |t|
      t.string :name
      t.integer :price
      t.string :description
      t.string :discount
    end
  end
end
