require 'sidekiq/scheduler'

# Only use the scheduler if it has been enabled
if Rails.application.config.enable_scheduler
  Sidekiq.configure_server do |config|
    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(File.expand_path("../scheduler.yml", __FILE__))
      Sidekiq::Scheduler.reload_schedule!
    end
  end
end