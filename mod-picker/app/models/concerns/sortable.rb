module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sort(options)
      results = self.where(nil)
      if options.present? && options.has_key?(:column) && options.has_key?(:direction)
        results = results.order("#{self.table_name}.#{options[:column]} #{options[:direction]}")
      end
      results
    end
  end
end