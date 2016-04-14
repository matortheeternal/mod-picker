class AddUserTitles < ActiveRecord::Migration
  def change
    create_table :user_titles do |t|
      t.integer   :game_id
      t.string    :title,         limit: 32
      t.integer   :rep_required
    end

    # add foreign keys
    add_foreign_key :user_titles, :games
  end
end
