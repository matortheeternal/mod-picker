class FixCategories < ActiveRecord::Migration
  def swap_category(from_category, to_category)
    catFrom = Category.find_by(name: from_category)
    catTo = Category.find_by(name: to_category)
    Mod.where(primary_category_id: catFrom.id).update_all("primary_category_id = #{catTo.id}")
    Mod.where(secondary_category_id: catFrom.id).update_all("secondary_category_id = #{catTo.id}")
    catFrom.destroy
  end

  def rename_category(old_name, new_name)
    Category.find_by(name: old_name).update(name: new_name)
  end

  def change
    # merge categories
    swap_category("Gameplay - Factions", "Gameplay - Quests")
    swap_category("Gameplay - Stealth", "Gameplay - AI & Combat")

    # rename categories
    rename_category("Gameplay - Classes and Races", "Gameplay - Classes & Races")
    rename_category("Gameplay - Quests", "Gameplay - Quests & Stories")
    rename_category("Gameplay - Magic", "Gameplay - Magic & Abilities")

    # create new categories
    catCharacter = Category.find_by(name: "Character Appearance")
    Category.where(parent_id: catCharacter.id).update_all("priority = priority + 1")
    Category.create(
        name: "Character Appearance - Body Mods",
        parent_id: catCharacter.id,
        description: "Mods that adjust body shapes or textures.",
        priority: 201
    )
  end
end
