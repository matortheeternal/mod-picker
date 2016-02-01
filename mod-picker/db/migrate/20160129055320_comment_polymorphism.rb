class CommentPolymorphism < ActiveRecord::Migration
  def change
    change_table :comments do |t|
      t.references :commentable, polymorphic: true, index: true
    end

    reversible do |dir|
      dir.up do
        execute("ALTER TABLE comments MODIFY commentable_id INT UNSIGNED")
      end
    end

    drop_table :user_comments
    drop_table :mod_list_comments
    drop_table :mod_comments
  end
end
