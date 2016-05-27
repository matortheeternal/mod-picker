class AddApprovalColumns < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :approved, :boolean, default: false
    add_column :install_order_notes, :approved, :boolean, default: false
    add_column :load_order_notes, :approved, :boolean, default: false
    add_column :reviews, :approved, :boolean, default: false

    add_column :compatibility_notes, :moderator_message, :string
    add_column :install_order_notes, :moderator_message, :string
    add_column :load_order_notes, :moderator_message, :string
    add_column :reviews, :moderator_message, :string
  end
end
