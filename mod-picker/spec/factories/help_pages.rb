# create_table "help_pages", force: :cascade do |t|
#    t.string   "name",      limit: 128,   null: false
#    t.datetime "submitted"
#    t.datetime "edited"
#    t.text     "text_body", limit: 65535
#  end

FactoryGirl.define do
  factory :help_page do
    name { Faker::Name.name }
    text_body { Faker::Lorem.sentence(20) }
  end
end
