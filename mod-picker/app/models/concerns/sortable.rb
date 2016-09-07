module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sort(options)
      results = self.where(nil)
      if options.present? && options.has_key?(:column) && options.has_key?(:direction)
        if options[:column].include?(",")
          results = results.
              select(sanitize_sql_array(["MAX(?) as scol", options[:column]]).tr("'", "")).
              order(sanitize_sql_array(["scol ?", options[:direction]]).tr("'", ""))
        elsif options[:column].include?(".")
          results = results.order(sanitize_sql_array(["? ?", options[:column], options[:direction]]).tr("'", ""))
        else
          results = results.order(options[:column] => options[:direction])
        end
      end
      results
    end
  end
end