class FixCuratorRequestColumnNames < ActiveRecord::Migration
  def change
    rename_column :curator_requests, :user_id, :submitted_by
    rename_column :curator_requests, :message, :text_body
    change_column :curator_requests, :text_body, :text, limit: 16384, null: false
  end
end
