class AddSpentRep < ActiveRecord::Migration
  def change
    add_column :user_reputations, :spent_rep, :float, null: false, default: 0.0, after: :given_rep
  end
end
