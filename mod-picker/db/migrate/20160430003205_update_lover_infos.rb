class UpdateLoverInfos < ActiveRecord::Migration
  def change
    change_table :lover_infos do |t|
      # basic columns
      t.column :mod_name, :string
      t.column :uploaded_by, :string, limit: 128
      t.column :date_submitted, :string
      t.column :date_updated, :string
      t.column :current_version, :string, limit: 32
      t.column :last_scraped, :datetime

      # statistics columns
      t.column :followers_count, :integer, default: 0
      t.column :file_size, :integer, default: 0
      t.column :views, :integer, default: 0
      t.column :downloads, :integer, default: 0
    end

    change_column :lover_infos, :id, :string
    add_foreign_key :lover_infos, :mods, column: :mod_id
  end
end
