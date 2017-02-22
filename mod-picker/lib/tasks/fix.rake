namespace :fix do
  desc "Tasks for fixing issues in the database"

  task mod_option_display_names: :environment do
    puts "\nFixing mod option display names"
    expr =  /(v?[0-9\.\_]+)?(\-[0-9]([0-9a-z\-]+))?\.(7z|rar|zip)/i
    ModOption.where("display_name LIKE '%.zip' OR display_name LIKE '%.7z' OR display_name LIKE '%.rar'").each do |option|
      match = expr.match(option.display_name)
      new_display_name = option.display_name.gsub(expr, '')
      next unless match && !new_display_name.blank?
      puts "#{option.display_name} -> #{new_display_name}"
      option.update(display_name: new_display_name)
    end
  end

  task duplicate_mod_list_mod_options: :environment do
    puts "\nFixing duplicate mod list mod options"
    ids = ModListModOption.select("MIN(id) as id").group(:mod_list_mod_id, :mod_option_id).collect(&:id)
    puts "Deleting #{ModListModOption.where("id NOT IN (?)", ids).count} duplicates"
    ModListModOption.where("id NOT IN (?)", ids).delete_all
  end
end