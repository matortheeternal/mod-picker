require 'rails_helper'

RSpec.describe LoverInfo, :model do
  it "should be valid with factory parameters" do
    info = build(:lover_info)

    expect(info).to be_valid
  end

  context "fields" do
     describe "mod_id" do
       it "should be invalid if blank" do
         info = build(:lover_info,
          mod_id: nil)

         expect(info).to be_invalid
         expect(info.errors[:mod_id]).to include("can't be blank")
       end
     end
   end 
end