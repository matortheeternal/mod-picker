module CounterCacheEnhancements
  extend ActiveSupport::Concern

  module ClassMethods
    # Custom counter updating code
    def update_counter(column, offset)
      self[column] += offset
      self.save
    end
  end
end