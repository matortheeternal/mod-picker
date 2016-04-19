module Sortable
  extend ActiveSupport::Concern

  module ClassMethods
    def autosort(sorting_params)
      results = self
      if sorting_params.has_key?(:sort) &&
          sorting_params[:sort].has_key?(:column) &&
          sorting_params[:sort].has_key?(:direction)
        results = results.order("#{sorting_params[:sort][:column]} #{sorting_params[:sort][:direction]}")
      end
      results
    end
  end
end