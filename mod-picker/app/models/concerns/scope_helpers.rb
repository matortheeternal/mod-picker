module ScopeHelpers
  extend ActiveSupport::Concern

  def range_scope(range, key, table)
    if table.present?
      where(table: {key: (range[:min]..range[:max])})
    else
      where(key: (range[:min]..range[:max]))
    end
  end
end