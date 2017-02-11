class AddModDetails < ActiveRecord::Migration
  def change
    add_column :mods, :description, :string, limit: 512, after: :authors
    add_column :mods, :notice, :string, limit: 128, after: :description
    add_column :mods, :support_link, :string, limit: 256, after: :notice
    add_column :mods, :issues_link, :string, limit: 256, after: :support_link
  end
end
