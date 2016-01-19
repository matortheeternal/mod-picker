class ReverseModInfoAssociations < ActiveRecord::Migration
  def change
    # first remove foreign keys
    remove_foreign_key :mods, column: :nm_id
    remove_foreign_key :mods, column: :ll_id
    remove_foreign_key :mods, column: :ws_id

    # then remove columns
    change_table :mods do |t|
      t.remove :nm_id
      t.remove :ll_id
      t.remove :ws_id
    end

    # add columns to info tables
    add_column :nexus_infos, :mod_id, :integer
    add_column :lover_infos, :mod_id, :integer
    add_column :workshop_infos, :mod_id, :integer

    # make info table columns unsigned integers
    reversible do |dir|
      dir.up do
        execute("ALTER TABLE nexus_infos MODIFY mod_id INT UNSIGNED NOT NULL")
        execute("ALTER TABLE lover_infos MODIFY mod_id INT UNSIGNED NOT NULL")
        execute("ALTER TABLE workshop_infos MODIFY mod_id INT UNSIGNED NOT NULL")
      end
    end
  end
end
