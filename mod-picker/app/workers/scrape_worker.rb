class ScrapeWorker
  include Sidekiq::Worker

  def perform
    # rescrape nexus if we're allowed to scrape nexus statistics
    puts "\nRescraping Nexus Mods"
    NexusInfo.can_recrape.find_each do |nexus_info|
      nexus_info.rescrape
    end

    # rescrape lab
    puts "\nRescraping Lover's Lab"
    LoverInfo.can_recrape.find_each do |lover_info|
      lover_info.rescrape
    end

    # rescrape workshop
    puts "\nRescraping Steam Workshop"
    WorkshopInfo.can_recrape.find_each do |workshop_info|
      workshop_info.rescrape
    end
  end
end