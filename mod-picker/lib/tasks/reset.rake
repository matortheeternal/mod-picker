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
    connection.execute("TRUNCATE TABLE category_priorities;")
    connection.execute("TRUNCATE TABLE review_sections;")
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

  task roles: :environment do
    puts "\nResetting user roles"
    User.where(role: ["user", "author"]).find_each do |u|
      u.update_mod_author_role
    end

    num_mod_authors = User.where(role: 'author').count
    puts "#{num_mod_authors} users with the mod author role"
  end

  task asset_paths: :environment do
    puts "\nResetting mod asset file paths"
    ModOption.find_each do |mo|
      mod_asset_files = mo.mod_asset_files.where(asset_file_id: nil)
      asset_paths = mod_asset_files.map { |maf| maf.subpath }
      basepaths = DataPathUtils.get_base_paths(asset_paths)
      unless basepaths.empty?
        puts "Fixing mod asset files for #{mo.mod.name} :: #{mo.name}"
        puts "  New base paths: #{basepaths.to_s}"
        ModAssetFile.apply_base_paths(mo.mod.game_id, mod_asset_files, basepaths)
      end
    end
  end

  task mod_metrics: :environment do
    puts "\nResetting mod metrics"
    Mod.all.find_each do |mod|
      next unless mod.reviews_count > 0
      puts "  Updating metrics for #{mod.name}"
      mod.compute_average_rating
      mod.compute_reputation
      mod.update_columns({
          :reputation => mod.reputation,
          :average_rating => mod.average_rating
      })
    end
  end

  task mod_lazy_counters: :environment do
    puts "\nResetting lazy mod counters"
    Mod.find_each do |mod|
      mod.update_lazy_counters
      mod.save_columns!(:mod_options_count, :asset_files_count, :plugins_count)
    end
  end

  task empty_mod_asset_files: :environment do
    puts "\nDestroying empty mod asset files"
    empty_mod_asset_files = ModAssetFile.where(subpath: "", asset_file_id: nil)
    count = empty_mod_asset_files.length
    empty_mod_asset_files.destroy_all
    puts "#{count} empty mod asset files destroyed"
  end

  task mod_approval: :environment do
    puts "\nApproving all mods"
    unapproved_mods_count = Mod.where(approved: false).count
    Mod.update_all(approved: true)
    puts "#{unapproved_mods_count} mods approved"
  end

  task help_page_approval: :environment do
    puts "\nApproving all help pages"
    unapproved_help_pages_count = HelpPage.where(approved: false).count
    HelpPage.update_all(approved: true)
    puts "#{unapproved_help_pages_count} help pages approved"
  end

  namespace :adult do
    task plugins: :environment do
      puts "\nResetting plugins has_adult_content values"
      Plugin.joins(:mod).update_all("plugins.has_adult_content = mods.has_adult_content")
      puts "#{Plugin.where(has_adult_content: true).count} plugins marked as having adult content"
    end
  end

  namespace :counters do
    task all: :environment do
      puts "\nResetting all counter cache columns"
      # TODO
    end

    task stars: :environment do
      Mod.reset_counter!(:mod_stars)
      ModList.reset_counter!(:mod_list_stars)
    end
  end
end
