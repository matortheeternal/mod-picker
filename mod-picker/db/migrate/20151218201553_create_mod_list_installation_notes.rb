class CreateModListInstallationNotes < ActiveRecord::Migration
  def change
    create_table :mod_list_installation_notes do |t|
      t.integer :ml_id
      t.integer :in_id
      t.integer :status

      t.timestamps null: false
    end
  end
end
