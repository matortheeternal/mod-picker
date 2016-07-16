class AddStandingToCorrectableContributions < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :standing, :integer, limit: 1, default: 0, null: false, after: :reputation
    add_column :install_order_notes, :standing, :integer, limit: 1, default: 0, null: false, after: :reputation
    add_column :load_order_notes, :standing, :integer, limit: 1, default: 0, null: false, after: :reputation
  end
end
