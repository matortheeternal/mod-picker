class AddTagsTable < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string    :text, null: false
      t.integer   :game_id, null: false
      t.integer   :submitted_by, null: false
      t.integer   :mods_count, :mod_lists_count
      t.boolean   :disabled, default: false
    end

    # add foreign key
    add_foreign_key :tags, :games
    add_foreign_key :tags, :users, column: :submitted_by
  end
end
