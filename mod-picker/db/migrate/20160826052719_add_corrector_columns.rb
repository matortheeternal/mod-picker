class AddCorrectorColumns < ActiveRecord::Migration
  def change
    add_column :compatibility_notes, :corrector_id, :integer, :after => :edited_by
    add_column :install_order_notes, :corrector_id, :integer, :after => :edited_by
    add_column :load_order_notes, :corrector_id, :integer, :after => :edited_by

    add_foreign_key :compatibility_notes, :users, :column => :corrector_id
    add_foreign_key :install_order_notes, :users, :column => :corrector_id
    add_foreign_key :load_order_notes, :users, :column => :corrector_id
  end
end
