class ReputationOffsetDefault5 < ActiveRecord::Migration
  def change
    change_column :user_reputations, :overall, :float, default: 5.0
    change_column :user_reputations, :offset, :float, default: 5.0
  end
end
