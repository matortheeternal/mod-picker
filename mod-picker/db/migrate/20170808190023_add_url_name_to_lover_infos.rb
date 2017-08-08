class AddUrlNameToLoverInfos < ActiveRecord::Migration
  include ActiveSupport::Inflector

  def change
    add_column :lover_infos, :url_id, :string, after: :id
    LoverInfo.find_each do |info|
      info.update(url_id: "#{info.id}-#{info.mod_name.parameterize}")
    end
    change_column :lover_infos, :url_id, :string, null: false
  end
end
