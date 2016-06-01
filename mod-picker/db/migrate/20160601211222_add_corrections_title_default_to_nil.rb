class AddCorrectionsTitleDefaultToNil < ActiveRecord::Migration
  def change
    change_column_default :corrections, :title, nil
  end
end
