class UpdateUserReputations < ActiveRecord::Migration
  def change
    remove_column :user_reputations, :audiovisual_design
    remove_column :user_reputations, :plugin_design
    remove_column :user_reputations, :utility_design
    remove_column :user_reputations, :script_design
    add_column :user_reputations, :site_rep, :float
    add_column :user_reputations, :contribution_rep, :float
    add_column :user_reputations, :author_rep, :float
    add_column :user_reputations, :given_rep, :float
    add_column :user_reputations, :last_computed, :datetime
    add_column :user_reputations, :dont_compute, :boolean
  end
end
