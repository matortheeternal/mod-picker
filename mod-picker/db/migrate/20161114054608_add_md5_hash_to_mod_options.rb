class AddMd5HashToModOptions < ActiveRecord::Migration
  def change
    add_column :mod_options, :md5_hash, :string, limit: 32, after: :size
  end
end
