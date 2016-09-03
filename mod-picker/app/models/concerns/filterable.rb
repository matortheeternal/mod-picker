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

    def parse_date(datestr)
      if datestr == "Now"
        DateTime.now.utc
      elsif (match = /([0-9]+) hours ago/.match(datestr))
        match[1].to_i.hours.ago
      else
        DateTime.strptime(datestr, "%m/%d/%Y")
      end
    end

    def parse_bytes(bytestr)
      sp = bytestr.split(' ')
      return 0 if !sp || sp.length < 2
      units = ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
      power = units.index(sp[1])
      if power == -1
        0
      else
        (sp[0].to_f * 1024 ** power).floor
      end
    end
  end
end