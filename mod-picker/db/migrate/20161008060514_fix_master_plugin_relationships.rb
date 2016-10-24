class FixMasterPluginRelationships < ActiveRecord::Migration
  def change
    pids = Plugin.ids
    Master.where("master_plugin_id NOT IN (?)", pids).each do |master|
      DummyMaster.create!({
          plugin_id: master.plugin_id,
          filename: "Unknown Master - Please Reupload the analysis",
          index: master.index
      })
      master.delete
    end

    add_foreign_key :masters, :plugins, column: :master_plugin_id
  end
end
