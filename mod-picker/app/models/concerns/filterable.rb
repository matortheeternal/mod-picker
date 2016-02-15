module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        if value.present?
          if value.include? '..' # value is a range
            range = value.split('..')
            results = results.public_send(key, range[0], range[1])
          else
            results = results.public_send(key, value)
          end
        end
      end
      results
    end
  end
end