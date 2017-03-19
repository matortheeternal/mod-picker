class CreateTagGroups < ActiveRecord::Migration
  def change
    create_table :tag_groups do |t|
      t.integer :game_id, null: false
      t.integer :category_id, null: false
      t.string :name, limit: 64, null: false
      t.string :exclusion_label, limit: 64
      t.string :param, limit: 10, null: false
      t.integer :tags_count, default: 0, null: false
    end

    add_foreign_key :tag_groups, :games
    add_foreign_key :tag_groups, :categories

    create_table :tag_group_tags do |t|
      t.integer :tag_group_id, null: false
      t.integer :tag_id, null: false
      t.integer :index, limit: 2, null: false
      t.string :alias, limit: 64
      t.integer :mod_tags_count, default: 0, null: false
    end

    add_foreign_key :tag_group_tags, :tag_groups
    add_foreign_key :tag_group_tags, :tags
  end
end
