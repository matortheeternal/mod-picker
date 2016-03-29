class AddQuotesTable < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.integer   :game_id, null: false
      t.string    :text, null: false
      t.string    :label, null: false, limit: 32
    end

    # add foreign key
    add_foreign_key :quotes, :games, column: :game_id
  end
end
