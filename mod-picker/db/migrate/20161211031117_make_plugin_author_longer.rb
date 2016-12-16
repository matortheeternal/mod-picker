class MakePluginAuthorLonger < ActiveRecord::Migration
  def change
    change_column :plugins, :author, :string, limit: 512
  end
end
