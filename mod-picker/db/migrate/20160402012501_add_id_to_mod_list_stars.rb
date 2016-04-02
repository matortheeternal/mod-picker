class AddIdToModListStars < ActiveRecord::Migration
  def change
    add_column :mod_list_stars, :id, :primary_key
  end
end
