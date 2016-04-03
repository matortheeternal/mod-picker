class AddModTagsTable < ActiveRecord::Migration
  def change
    create_table :mod_tags, id: false do |t|
      t.integer   :game_id, null: false
      t.integer   :mod_id, null: false
      t.string    :tag, null: false
    end

    # add foreign key
    add_foreign_key :mod_tags, :games, column: :game_id
    add_foreign_key :mod_tags, :mods, column: :mod_id
  end
end
