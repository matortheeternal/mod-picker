class SetQualityMetricDefaults < ActiveRecord::Migration
  def change
    change_column :mods, :average_rating, :float, default: 0.0
    change_column :mods, :reputation, :float, default: 0.0
  end
end
