class AddInstallOrderNotesTable < ActiveRecord::Migration
  def change
    create_table :install_order_notes do |t|
      t.integer   :submitted_by, null: false
      t.integer   :install_first, null: false
      t.integer   :install_second, null: false
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :install_order_notes, :users, column: :submitted_by
    add_foreign_key :install_order_notes, :mods, column: :install_first
    add_foreign_key :install_order_notes, :mods, column: :install_second
  end
end
