class AddCategoriesTable < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :parent_id,   null: true
      t.text    :name,        limit: 255
      t.text    :description, limit: 65535
    end
    
    create_table :category_priorities, id: false do |t|
      t.integer :dominant_id
      t.integer :recessive_id
    end

    reversible do |dir|
      dir.up do
        # alter id to be unsigned
        execute <<-SQL
          ALTER TABLE categories MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;
        SQL
        # alter parent_id to be unsigned
        execute <<-SQL
          ALTER TABLE categories MODIFY parent_id INT UNSIGNED NULL;
        SQL
        # alter dominant_id to be unsigned
        execute <<-SQL
          ALTER TABLE category_priorities MODIFY dominant_id INT UNSIGNED;
        SQL
        # alter recessive_id to be unsigned
        execute <<-SQL
          ALTER TABLE category_priorities MODIFY recessive_id INT UNSIGNED;
        SQL
      end
    end

    add_foreign_key :categories, :categories, column: :parent_id
    add_foreign_key :category_priorities, :categories, column: :dominant_id
    add_foreign_key :category_priorities, :categories, column: :recessive_id
  end
end
