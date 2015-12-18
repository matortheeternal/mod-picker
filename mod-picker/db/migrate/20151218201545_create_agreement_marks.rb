class CreateAgreementMarks < ActiveRecord::Migration
  def change
    create_table :agreement_marks do |t|
      t.integer :inc_id
      t.integer :submitted_by
      t.boolean :agree

      t.timestamps null: false
    end
  end
end
