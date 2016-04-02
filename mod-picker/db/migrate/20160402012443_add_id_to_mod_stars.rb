class AddIdToModStars < ActiveRecord::Migration
  def change
    add_column :mod_stars, :id, :primary_key
  end
end
