class AddDefaultValueToCorrectionsTitle < ActiveRecord::Migration
  def change
    change_column_default :corrections, :title, ""
  end
end
