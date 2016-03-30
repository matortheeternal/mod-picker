class AddModListTagsTable < ActiveRecord::Migration
  def change
    create_table :mod_list_tags do |t|
      t.string    :tag, null: false, length: 32
      t.integer   :game_id, null: false
      t.integer   :mod_list_id, null: false
      t.integer   :submitted_by, null: false
    end

    # add foreign keys
    add_foreign_key :mod_list_tags, :games
    add_foreign_key :mod_list_tags, :mod_lists
    add_foreign_key :mod_list_tags, :users, column: :submitted_by

    # add submitted_by column to mod_tags table
    add_column :mod_tags, :submitted_by, :integer
    add_foreign_key :mod_tags, :users, column: :submitted_by
  end
end
