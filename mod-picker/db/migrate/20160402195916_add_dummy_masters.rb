class AddDummyMasters < ActiveRecord::Migration
  def change
    create_table :dummy_masters, id: false do |t|
      t.integer   :plugin_id, limit: 4
      t.string    :filename,  limit: 64
      t.integer   :index,     limit: 4
    end

    # add foreign keys
    add_foreign_key :dummy_masters, :plugins
  end
end
