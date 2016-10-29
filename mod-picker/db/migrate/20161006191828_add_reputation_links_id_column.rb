class AddReputationLinksIdColumn < ActiveRecord::Migration
  def change
    add_column :reputation_links, :id, :primary_key
  end
end
