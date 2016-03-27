require 'rails_helper'

describe AgreementMark do
  it "should be valid with factory parameters" do
    agree = build(:agreement_mark)

    expect(agree).to be_valid
  end
end