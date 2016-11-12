class AddHasAdultContentPlugins < ActiveRecord::Migration
  def change
    add_column :plugins, :has_adult_content, :boolean, default: false, null: false
  end
end
