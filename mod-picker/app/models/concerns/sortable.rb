module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def sort(sorting_params)
      results = self.where(nil)
      if sorting_params.present? && sorting_params.has_key?(:column) && sorting_params.has_key?(:direction)
        results = results.order("#{self.table_name}.#{sorting_params[:column]} #{sorting_params[:direction]}")
      end
      results
    end
  end
end