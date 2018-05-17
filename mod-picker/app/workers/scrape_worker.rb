class ScrapeWorker
  include Sidekiq::Worker

  def perform
    # rescrape nexus if we're allowed to scrape nexus statistics
    puts "\nRescraping Nexus Mods"
    NexusInfo.can_recrape.find_each do |nexus_info|
      begin
        nexus_info.rescrape
      rescue Exception => e
        puts e
      end
    end

    # rescrape lab
    puts "\nRescraping Lover's Lab"
    LoverInfo.can_recrape.find_each do |lover_info|
      begin
        lover_info.rescrape
      rescue Exception => e
        puts e
      end
    end

    # rescrape workshop
    puts "\nRescraping Steam Workshop"
    WorkshopInfo.can_recrape.find_each do |workshop_info|
      begin
        workshop_info.rescrape
      rescue Exception => e
        puts e
      end
    end
  end
end