class CreateBaseReports < ActiveRecord::Migration
  def change
    create_table :base_reports do |t|
      t.integer :reportable_id, null: false
      t.string :reportable_type, null: false

      t.timestamps null: false
    end
  end
end
