class CorrectPluginOverrideMap < ActiveRecord::Migration
  def change
    change_table :plugin_override_map do |t|
      t.remove :is_itm
      t.remove :is_itpo
      t.remove :is_udr
    end
  end
end
