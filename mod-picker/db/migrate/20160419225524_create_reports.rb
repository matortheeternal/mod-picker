class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.integer :base_report_id, null: false
      t.integer :submitted_by, null: false
      t.integer :type, limit: 1, null: false
      t.string :note, limit: 128

      t.timestamps null: false
    end

    add_foreign_key :reports, :users, :column => :submitted_by
    add_foreign_key :reports, :base_reports
  end
end
