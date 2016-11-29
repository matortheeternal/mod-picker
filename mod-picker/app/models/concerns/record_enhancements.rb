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

  def next_id
    connection = ActiveRecord::Base.connection
    connection.execute("SELECT MIN(t1.id + 1) AS nextID FROM #{self.class.table_name} t1 LEFT JOIN #{self.class.table_name} t2 ON t1.id + 1 = t2.id WHERE t2.id IS NULL;").first[0]
  end
end