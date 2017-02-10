class FixItemsWeaponsCategoryDescription < ActiveRecord::Migration
  def change
    Category.find_by(name: "Items - Weapons").update(description: "Mods that add sticks you can stab, squish, or shoot people with.")
  end
end
