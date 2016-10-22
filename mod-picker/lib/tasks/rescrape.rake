namespace :rescrape do
  task workshop: :environment do
    WorkshopInfo.all.find_each do |info|
      info.scrape
    end
  end

  task nexus: :environment do
    NexusInfo.all.find_each do |info|
      info.scrape
    end
  end

  task lab: :environment do
    LoverInfo.all.find_each do |info|
      info.scrape
    end
  end
end