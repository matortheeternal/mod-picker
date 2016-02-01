class HelpfulMarkPolymorphism < ActiveRecord::Migration
  def change
    remove_foreign_key :helpful_marks, column: 'review_id'
    remove_foreign_key :helpful_marks, column: 'compatibility_note_id'
    remove_foreign_key :helpful_marks, column: 'installation_note_id'

    remove_column :helpful_marks, :review_id
    remove_column :helpful_marks, :compatibility_note_id
    remove_column :helpful_marks, :installation_note_id

    change_table :helpful_marks do |t|
      t.references :helpfulable, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE helpful_marks MODIFY helpfulable_id INT UNSIGNED")
      end
    end
  end
end
