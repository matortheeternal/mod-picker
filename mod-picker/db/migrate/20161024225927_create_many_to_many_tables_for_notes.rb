class CreateManyToManyTablesForNotes < ActiveRecord::Migration
  def create_many_to_many_table(first_name, second_name)
    new_table_name = :"#{first_name}_#{second_name.to_s.pluralize}"
    first_table = :"#{first_name.to_s.pluralize}"
    second_table = :"#{second_name.to_s.pluralize}"

    create_table new_table_name, id: false do |t|
      t.integer :"#{first_name}_id", null: false
      t.integer :"#{second_name}_id", null: false
      t.integer :index, limit: 1, null: false
    end

    add_foreign_key new_table_name, first_table
    add_foreign_key new_table_name, second_table
  end

  def map_notes(note_model, many_to_many_model, label)
    note_model.all.find_each do |note|
      many_to_many_model.create({
          :"#{label}_id" => note.public_send(:"first_#{label}_id"),
          :"#{note_model.name.underscore}_id" => note.id,
          index: 0
      })
      many_to_many_model.create({
          :"#{label}_id" => note.public_send(:"second_#{label}_id"),
          :"#{note_model.name.underscore}_id" => note.id,
          index: 1
      })
    end
  end

  def remove_note_columns(note_model, label)
    # prepare local variables
    table = note_model.table_name.to_sym
    first_column = "first_#{label}_id"
    second_column = "second_#{label}_id"

    # remove foreign keys
    remove_foreign_key table, column: first_column
    remove_foreign_key table, column: second_column

    # remove columns
    remove_column table, first_column
    remove_column table, second_column
  end

  def change
    # CREATE NEW TABLES
    create_many_to_many_table(:mod, :compatibility_note)
    create_many_to_many_table(:mod, :install_order_note)
    create_many_to_many_table(:plugin, :load_order_note)

    # MOVE NOTE ID COLUMNS INTO NEW TABLES
    map_notes(CompatibilityNote, ModCompatibilityNote, "mod")
    map_notes(InstallOrderNote, ModInstallOrderNote, "mod")
    map_notes(LoadOrderNote, PluginLoadOrderNote, "plugin")

    # REMOVE NOTE ID COLUMNS
    remove_note_columns(CompatibilityNote, "mod")
    remove_note_columns(InstallOrderNote, "mod")
    remove_note_columns(LoadOrderNote, "plugin")
  end
end
