class FixTagTextLength < ActiveRecord::Migration
  def change
    change_column :tags, :string, limit: 32, null: false
  end
end
