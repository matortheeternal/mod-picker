class ScrapeWorker
  include Sidekiq::Worker

  def perform
    # rescrape nexus if we're allowed to scrape nexus statistics
    if Rails.application.config.scrape_nexus_statistics
      puts "\nRescraping Nexus Mods"
      NexusInfo.can_recrape.find_each do |nexus_info|
        nexus_info.scrape
      end
    end

    # rescrape lab
    puts "\nRescraping Lover's Lab"
    LoverInfo.can_recrape.find_each do |lover_info|
      lover_info.scrape
    end

    # rescrape workshop
    if Rails.application.config.scrape_workshop_statistics
      puts "\nRescraping Steam Workshop"
      WorkshopInfo.can_recrape.find_each do |workshop_info|
        workshop_info.scrape
      end
    end
  end
end