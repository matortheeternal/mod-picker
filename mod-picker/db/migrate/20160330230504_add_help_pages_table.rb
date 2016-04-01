class AddHelpPagesTable < ActiveRecord::Migration
  def change
    create_table :help_pages do |t|
      t.string   :name, null: false, limit: 128
      t.datetime  :submitted
      t.datetime  :edited
      t.text      :text_body
    end
  end
end
