class AddReputationToContributions < ActiveRecord::Migration
  def change
    add_column :reviews, :reputation, :float, default: 0.0, null: false, after: :overall_rating
    add_column :compatibility_notes, :reputation, :float, default: 0.0, null: false, after: :moderator_message
    add_column :install_order_notes, :reputation, :float, default: 0.0, null: false, after: :moderator_message
    add_column :load_order_notes, :reputation, :float, default: 0.0, null: false, after: :moderator_message
  end
end
