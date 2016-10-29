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
end