module RecordEnhancements
  extend ActiveSupport::Concern

  def column_changes_hash(names)
    column_changes = changes.inject({}) { |h, (k, v)|
      h[k] = v[1] if self.class.column_names.include?(k); h }
    return column_changes unless names.present?
    column_changes.symbolize_keys.slice(*names)
  end

  def save_columns!(*names)
    column_values = column_changes_hash(names)
    update_columns(column_values) unless column_values.empty?
    changes_applied
  end

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

  module ClassMethods
    def update_all_counters(model, column, foreign_key)
      model.update_all("#{column} = (SELECT COUNT(*) from #{table_name} WHERE #{model.table_name}.id = #{table_name}.#{foreign_key})")
    end
  end
end