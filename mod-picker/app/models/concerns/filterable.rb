module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter(filtering_params)
      results = self.where(nil)
      filtering_params.each do |key, value|
        if value.present?
          if value.min.present? || value.max.present?
            results = results.public_send(key, value.min, value.max)
          else
            results = results.public_send(key, value)
          end
        end
      end
      results
    end
  end
end