class AddModVersionInstallOrderNotesTable < ActiveRecord::Migration
  def change
    create_table :mod_version_install_order_notes do |t|
      t.integer   :mod_version_id, null: false
      t.integer    :install_order_note_id, null: false
    end

    add_foreign_key :mod_version_install_order_notes, :mod_versions
    add_foreign_key :mod_version_install_order_notes, :install_order_notes
  end
end
