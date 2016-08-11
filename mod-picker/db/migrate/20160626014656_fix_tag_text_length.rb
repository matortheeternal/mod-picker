class FixTagTextLength < ActiveRecord::Migration
  def change
    change_column :tags, :text, :string, limit: 32, null: false
  end
end
