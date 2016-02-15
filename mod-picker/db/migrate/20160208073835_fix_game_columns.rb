class FixGameColumns < ActiveRecord::Migration
  def change
    rename_column :games, :short_name, :display_name
    add_column :games, :nexus_name, :string, :limit => 16
  end
end
