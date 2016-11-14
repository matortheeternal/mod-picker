class FixCategoryPriorityTypos < ActiveRecord::Migration
  def change
    catQuests = Category.where(name: "Gameplay - Quests").first
    catNewChars = Category.where(name: "New Characters").first
    catImmersionAndRolePlaying = Category.where(name: "Gameplay - Immersion & Role-playing").first

    CategoryPriority.find_by(
        dominant_id: catQuests.id,
        recessive_id: catNewChars.id
    ).update(description: 'New or altered quests often involve new characters.')

    CategoryPriority.find_by(
        dominant_id: catQuests.id,
        recessive_id: catImmersionAndRolePlaying.id
    ).update(description: 'New or altered quests often increase gameplay immersion and offer new role-playing experiences.')
  end
end
