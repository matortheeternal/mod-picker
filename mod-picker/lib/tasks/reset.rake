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
end
