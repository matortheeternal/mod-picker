class AddDefaultTextBodyToConfigFiles < ActiveRecord::Migration
  def change
    add_column :config_files, :default_text_body, :text
  end
end
