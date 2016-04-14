require 'rails_helper'

# create_table "help_pages", force: :cascade do |t|
#   t.string   "name",      limit: 128,   null: false
#   t.datetime "submitted"
#   t.datetime "edited"
#   t.text     "text_body", limit: 65535
# end

RSpec.describe HelpPage, :model, :wip do
  fixtures :help_pages

  it "should have a valid factory" do
    expect(create(:help_page)).to be_valid
  end

  it "should have valid fixtures" do
    expect(help_pages(:help_about_page)).to be_valid
    expect(help_pages(:help_contact_page)).to be_valid
    expect(help_pages(:help_support_page)).to be_valid
  end
end
