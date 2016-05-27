module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        if value.present?
          results = results.public_send(key, value)
        end
      end
      results
    end

    def parseDate(datestr)
      if datestr == "Now"
        DateTime.now.utc
      elsif match = /([0-9]+) hours ago/.match(datestr)
        match[1].to_i.hours.ago
      else
        DateTime.strptime(datestr, "%m/%d/%Y")
      end
    end
  end
end