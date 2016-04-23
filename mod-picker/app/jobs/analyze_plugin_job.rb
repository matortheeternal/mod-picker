class AnalyzePluginJob < ActiveJob::Base
  include SuckerPunch::Job
  workers 1

  def perform(filename, game_name, game_abbr, mod_version_id)
    # Do something later
    SuckerPunch.logger.info "Analyzing plugin #{filename} for game #{game_name}"
    ## YOU BETTER USE BACKWARD SLASHES
    ## OR THINGS BAD
    command = "start /wait /D \"#{Rails.root}\\app\\assets\" \"\" \"#{Rails.root}\\bin\\ModDump.exe\" \"#{Rails.root}\\app\\assets\\plugins\\#{game_name}\\#{filename}\" \"-#{game_abbr}\""
    SuckerPunch.logger.info "Executing > #{command}"
    system("#{command}")

    # load the json into the database
    File.open(Rails.root.join('app','assets', 'dumps', "#{game_name}", filename + '.json'), 'rb') do |f|
      data_hash = JSON.parse(f)
      Plugin.create(data_hash)
    end
  end
end
