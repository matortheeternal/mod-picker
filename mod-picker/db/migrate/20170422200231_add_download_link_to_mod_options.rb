class AddDownloadLinkToModOptions < ActiveRecord::Migration
  def change
    add_column :mod_options, :download_link, :string, after: :display_name
  end
end
