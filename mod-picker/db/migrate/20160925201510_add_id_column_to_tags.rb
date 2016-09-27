class AddIdColumnToTags < ActiveRecord::Migration
  def change
    add_column :mod_tags, :id, :primary_key
  end
end
