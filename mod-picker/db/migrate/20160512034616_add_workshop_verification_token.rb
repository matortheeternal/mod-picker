class AddWorkshopVerificationToken < ActiveRecord::Migration
  def change
    add_column :user_bios, :workshop_verification_token, :string, limit: 32
  end
end
