module EnhancedRecord
  class Base < ActiveRecord::Base
    # Custom counter updating code
    def update_counter(column, offset)
      self[column] += offset
      self.save
    end
  end
end