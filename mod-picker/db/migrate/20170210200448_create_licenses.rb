class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :name, limit: 128, null: false
      t.string :acronym, limit: 16
      t.string :wikipedia_page, limit: 64
      t.string :description, limit: 512
      t.integer :clauses, limit: 1, default: 0, null: false
      t.string :license_type, limit: 32, null: false
      t.boolean :code, default: false, null: false
      t.boolean :assets, default: false, null: false
      t.integer :credit, limit: 1, default: -1, null: false
      t.integer :commercial, limit: 1, default: -1, null: false
      t.integer :redistribution, limit: 1, default: -1, null: false
      t.integer :modification, limit: 1, default: -1, null: false
      t.integer :private_use, limit: 1, default: -1, null: false
      t.integer :include, limit: 1, default: -1, null: false
    end

    create_table :license_options do |t|
      t.integer :license_id, null: false
      t.string :name, limit: 128, null: false
      t.string :acronym, limit: 16
      t.string :tldr, limit: 128
      t.string :link, limit: 256
    end

    add_foreign_key :license_options, :licenses

    create_table :mod_licenses do |t|
      t.integer :mod_id, null: false
      t.integer :license_id, null: false
      t.integer :license_option_id
      # this is here for searching purposes and custom licenses
      t.integer :credit, limit: 1, default: -1, null: false
      t.integer :commercial, limit: 1, default: -1, null: false
      t.integer :redistribution, limit: 1, default: -1, null: false
      t.integer :modification, limit: 1, default: -1, null: false
      t.integer :private_use, limit: 1, default: -1, null: false
      t.integer :include, limit: 1, default: -1, null: false
      # for custom licenses
      t.text :text_body, limit: 16384
    end

    add_foreign_key :mod_licenses, :mods
    add_foreign_key :mod_licenses, :licenses
    add_foreign_key :mod_licenses, :license_options
  end
end
