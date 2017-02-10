class CreateRelatedModNotes < ActiveRecord::Migration
  def change
    create_table :related_mod_notes do |t|
      t.integer :game_id, null: false
      t.integer :submitted_by, null: false
      t.integer :edited_by, null: false
      t.integer :status, limit: 1, default: 0, null: false
      t.integer :first_mod_id, null: false
      t.integer :second_mod_id, null: false
      t.text :text_body, null: false
      t.string :edit_summary
      t.string :moderator_message
      t.float :reputation, default: 0.0, null: false
      t.integer :helpful_count, default: 0, null: false
      t.integer :not_helpful_count, default: 0, null: false
      t.boolean :approved, default: false, null: false
      t.boolean :hidden, default: false, null: false
      t.boolean :has_adult_content, default: false, null: false
      t.datetime :submitted, null: false
      t.datetime :edited
    end

    add_foreign_key :related_mod_notes, :games
    add_foreign_key :related_mod_notes, :users, column: :submitted_by
    add_foreign_key :related_mod_notes, :users, column: :edited_by
    add_foreign_key :related_mod_notes, :mods, column: :first_mod_id
    add_foreign_key :related_mod_notes, :mods, column: :second_mod_id
  end
end
