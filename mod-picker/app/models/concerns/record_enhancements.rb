module RecordEnhancements
  extend ActiveSupport::Concern

  # Custom counter updating code
  def update_counter(column, offset)
    # this updates it in memory
    self[column] += offset
    # we do it this way to avoid calling save - we don't want to trigger callbacks
    operator = offset < 0 ? '-' : '+'
    self.raw_update("#{column} = #{column} #{operator} #{offset.abs}")
  end

  def save_counters(columns)
    hash = {}
    instance = self
    columns.each do |column|
      hash[column] = instance.public_send(column)
    end
    self.raw_update(hash)
  end

  # performs a raw update query to a single record
  def raw_update(args)
    self.class.unscoped.where(self.class.primary_key => id).update_all(args)
  end
end