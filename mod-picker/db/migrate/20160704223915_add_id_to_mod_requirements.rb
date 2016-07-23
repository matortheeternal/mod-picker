class AddIdToModRequirements < ActiveRecord::Migration
  def change
    add_column :mod_requirements, :id, :primary_key
  end
end
