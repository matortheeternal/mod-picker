module CounterCacheEnhancements
  extend ActiveSupport::Concern

  # Custom counter updating code
  def self.update_counter(column, offset)
    self[column] += offset
    self.save
  end
end