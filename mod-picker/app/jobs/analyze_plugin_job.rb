class AnalyzePluginJob < ActiveJob::Base
  include SuckerPunch::Job
  workers 1

  def perform(filename, game_name, game_abbr)
    # Do something later
    byebug
    puts "Analyzing plugin #{filename} for game #{game_name}"
    command = "start /B \"\" \"#{Rails.root}/bin/ModDump.exe\" \"#{Rails.root}/app/assets/plugins/#{game_name}/#{filename}\" -#{game_abbr}"
    puts "Executing > #{command}"
    system("#{command}")
  end
end
