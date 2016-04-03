class AddLoadOrderNotesTable < ActiveRecord::Migration
  def change
    create_table :load_order_notes do |t|
      t.integer   :submitted_by, null: false
      t.integer   :load_first, null: false
      t.integer   :load_second, null: false
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end

    # add foreign keys
    add_foreign_key :load_order_notes, :users, column: :submitted_by
    add_foreign_key :load_order_notes, :plugins, column: :load_first
    add_foreign_key :load_order_notes, :plugins, column: :load_second
  end
end
