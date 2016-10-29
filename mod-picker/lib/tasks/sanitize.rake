namespace :sanitize do
  task users: :environment do
    puts "Sanitizing user emails, passwords, and tokens"
    base = "0A1B2C3D4E5F6"
    User.update_all("email = CONCAT('sanitized', users.id, '@mail.com'), encrypted_password = CONCAT('#{base}.', users.id), invitation_token = CONCAT('#{base}', users.id), reset_password_token = null, confirmation_token = null")
  end

  task bios: :environment do
    puts "Sanitizing user bio verification tokens"
    UserBio.update_all(
        nexus_verification_token: 'ModPicker:00000000',
        lover_verification_token: 'ModPicker:00000000',
        workshop_verification_token: 'ModPicker:00000000'
    )
  end
end

task sanitize: :environment do
  Rake::Task['sanitize:users'].invoke
  Rake::Task['sanitize:bios'].invoke
end