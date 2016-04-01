class AddModVersionRequirementsTable < ActiveRecord::Migration
  def change
    create_table :mod_version_requirements, id: false do |t|
      t.integer   :mod_version_id, null: false
      t.integer   :required_id, null: false
    end

    # add foreign keys
    add_foreign_key :mod_version_requirements, :mod_versions, column: :mod_version_id
    add_foreign_key :mod_version_requirements, :mod_versions, column: :required_id
  end
end
