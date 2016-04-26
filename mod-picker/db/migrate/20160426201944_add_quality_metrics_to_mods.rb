class AddQualityMetricsToMods < ActiveRecord::Migration
  def change
    add_column :mods, :reputation, :float
    add_column :mods, :average_rating, :float
  end
end
