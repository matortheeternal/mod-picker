class SetDefaultsToUserAssociations < ActiveRecord::Migration
  def change
    change_column :user_reputations, :overall, :float, default: 0.0
    change_column :user_reputations, :offset, :float, default: 0.0
    change_column :user_settings, :allow_comments, :boolean, default: true
  end
end
