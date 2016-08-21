require "#{Rails.root}/db/static_seeds"

namespace :reset do
  desc "Tasks for resetting the database"

  task ids: :environment do
    puts "\nResetting IDs"
    connection = ActiveRecord::Base.connection

    # reset ids in each table
    table_names = ActiveRecord::Base.connection.tables - ["schema_migrations"]
    table_names.each do |table|
      puts "    Resetting #{table}"
      connection.execute("ALTER TABLE #{table} AUTO_INCREMENT = 1;")
    end

    puts "IDs reset successfully"
  end

  task clear: :environment do
    puts "\nResetting database"
    connection = ActiveRecord::Base.connection

    # truncate each table
    table_names = ActiveRecord::Base.connection.tables - ["schema_migrations"]
    connection.execute("SET FOREIGN_KEY_CHECKS=0;")
    table_names.each do |table|
      puts "    Truncating #{table}"
      connection.execute("TRUNCATE TABLE #{table};")
    end
    connection.execute("SET FOREIGN_KEY_CHECKS=1;")

    # all done
    puts "Database reset successfully"
  end

  task categories: :environment do
    puts "\nResetting categories"
    connection = ActiveRecord::Base.connection
    byebug

    mods = []
    Mod.all.each do |mod|
      categories = []
      categories.push(mod.primary_category.name) if mod.primary_category_id
      categories.push(mod.secondary_category.name) if mod.secondary_category_id
      mods.push({
          id: mod.id,
          categories: categories
      })
    end

    Mod.update_all(primary_category_id: nil, secondary_category_id: nil)
    connection.execute("SET FOREIGN_KEY_CHECKS=0;")
    connection.execute("TRUNCATE TABLE categories;")
    connection.execute("SET FOREIGN_KEY_CHECKS=1;")
    seed_categories

    Mod.all.each do |mod|
      item = mods.find {|item| item[:id] == mod.id }
      update_hash = {}
      if item[:categories].length > 0
        primary_category = Category.find_by(name: item[:categories][0])
        update_hash[:primary_category_id] = primary_category.id if primary_category.present?
      end
      if item[:categories].length > 1
        secondary_category = Category.find_by(name: item[:categories][1])
        update_hash[:secondary_category_id] = secondary_category.id if secondary_category.present?
      end
      mod.update(update_hash)
    end

    # all done
    puts "Categories reset successfully"
  end
end
